# flutter_webrtc_rs

A Flutter WebRTC plugin with [webrtc-rs](https://github.com/webrtc-rs/webrtc) (pure
Rust, sans-I/O core + async wrapper) as its transport core, bound to Dart via
[flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge).

Built as a standalone package, independent of anything else in this repo.

## Why this exists instead of `flutter_webrtc`

`flutter_webrtc` wraps Google's libwebrtc. libwebrtc's C++ API has a
`FrameEncryptorInterface`/`FrameDecryptorInterface` seam made for exactly this, but
`flutter_webrtc`'s prebuilt binaries only expose it through a fixed AES-GCM
`RTCFrameCryptor`, not a hook you can drive from Dart or plug DAVE into. Getting DAVE
(or any custom frame-level E2EE) working on top of `flutter_webrtc` means forking and
rebuilding libwebrtc across five platforms.

This library sidesteps that by keeping transport (ICE/DTLS-SRTP/SCTP), codecs, and
encryption cleanly separated, but **in the same crate** - codecs live here
([`video_codec.rs`](rust/src/api/video_codec.rs) for H264 today) rather than being
pushed out to every consumer to reimplement:

- **Transport never touches encoded-frame content.**
  [`RtcMediaSender::write_encoded_frame`](rust/src/api/media.rs) takes already-encoded
  bytes and packetizes+sends them; [`RtcRemoteTrack::packets`](rust/src/api/media.rs)
  reassembles RTP packets per the negotiated codec (H264 FU-A fragments are
  depacketized here, not left to the caller) and hands back complete encoded frames.
  Neither transforms what's *inside* those bytes.
- **Encode/decode is this crate's job; encryption is the caller's.** Call
  [`H264Encoder`](rust/src/api/video_codec.rs)/[`H264Decoder`](rust/src/api/video_codec.rs)
  (or your own Opus encoder/decoder - that side stays a Dart-side concern for now,
  see `packages/opus`) to get encoded bytes, encrypt those with DAVE (or anything
  else) *before* calling `write_encoded_frame`, and decrypt what `packets` gives you
  *before* decoding it. The encryption step is the one thing genuinely free of any
  Rust-side plumbing - this layer never needs to know it happened.

## Status

Validated end to end on macOS: two `RtcPeerConnection`s can signal (offer/answer +
ICE candidate exchange as JSON, in place of a real signaling server), establish
ICE/DTLS/SCTP, open a data channel, and exchange messages both ways - proven at two
levels:

- `rust/tests/webrtc_loopback.rs` - pure Rust, no Dart/Flutter involved. Validates the
  webrtc-rs transport itself: a data channel round trip and an audio-track round trip
  (arbitrary "encoded frame" bytes sent through `TrackLocalStaticSample`/`add_track`
  and confirmed byte-identical coming out of `on_track`'s RTP payloads - the exact
  mechanism DAVE would ride on).
- `example/integration_test/loopback_test.dart` - the same scenario through the real
  Flutter app and the actual flutter_rust_bridge `StreamSink`/opaque-handle plumbing,
  which the Rust-only tests can't exercise.

Run them:

```bash
cargo test --manifest-path rust/Cargo.toml
cd example && flutter test integration_test/loopback_test.dart -d macos
```

**Not yet done:** video (codec registration and RTP payload handling are already
wired via `MediaEngine::register_default_codecs()`, since Discord's SFU prefers
H264/AV1/H265 - see below - and negotiates VP8/VP9 too, but there's no camera capture
or hardware/software encode-decode here yet, and no texture output for video frames);
Android/iOS/Windows/Linux (only macOS has been build-tested; webrtc-rs itself is
cross-platform pure Rust with no per-platform native toolchain needed, so this should
mostly be a cargokit-target-list exercise, but it is untested); a jitter buffer above
the RTP layer (webrtc-rs's `rtc-interceptor` crate has one - `nack`, `pacing`, `gcc`,
`twcc` too - but this plugin doesn't wire it up yet).

## Two real bugs this validation caught

Worth recording since they'll bite anyone extending this:

1. **`TrackLocalStaticSample` silently drops SSRCs with no codec.** It only builds an
   RTP packetizer for an SSRC whose `RTCRtpEncodingParameters.codec` resolves to a
   real payloader - leave it at `Default::default()` (as the official examples'
   pattern makes easy to do by accident) and `write_sample`/`sample_writer` fail with
   "codec not found" for every frame. See the comment in
   [`build_local_track`](rust/src/api/media.rs).
2. **A `StreamSink`-only Rust function must be `async fn`, not a plain sync `fn`.**
   flutter_rust_bridge dispatches sync functions through a raw OS-thread threadpool
   with no ambient Tokio runtime; webrtc-rs's `TokioRuntime::spawn` uses the ambient
   `tokio::spawn()` free function (by design - see its own source comments on why it
   takes an explicit `&dyn Runtime` everywhere internally instead), which panics with
   "there is no reactor running" when called from that threadpool. Async functions go
   through flutter_rust_bridge's async dispatch path instead, which does have ambient
   context. `RtcPeerConnection::events`, `RtcDataChannel::events`, and
   `RtcRemoteTrack::packets` are all `async fn` for this reason even though none of
   them otherwise need to `.await` anything.

And one packaging gotcha, not a code bug: **macOS App Sandbox needs both
`com.apple.security.network.client` and `.network.server` entitlements.** Without
`network.client`, outbound UDP sends fail even on an already-bound socket that has
`network.server` - ICE candidates gather fine, connectivity checks get sent, and
nothing ever comes back, so it reads as a silent hang at `IceConnectionState.checking`
until webrtc-rs's own ICE timeout fails it ~30s later. See
`example/macos/Runner/*.entitlements` - any app embedding this library needs both.

## Architecture

```
rust/                     - the actual webrtc-rs binding (flutter_rust_bridge_codegen
  src/api/
    peer_connection.rs      RtcPeerConnection: signaling, ICE, data channels, media senders
    media.rs                 RtcMediaSender (send encoded frames) / RtcRemoteTrack (receive RTP)
    data_channel.rs          RtcDataChannel
    types.rs                  Config + event types crossing the Dart boundary
    runtime_ctx.rs            The one process-wide Arc<dyn webrtc::runtime::Runtime>
  tests/webrtc_loopback.rs  Pure-Rust validation (see Status)
lib/                       - generated Dart bindings + this package's Dart API surface
example/                   - a Flutter app + integration test exercising the real bridge
```

### SDP/ICE candidates cross as JSON

`RtcPeerConnection.createOffer()`/`createAnswer()`/`localDescription()` return
JSON-encoded `RTCSessionDescription`s; `addIceCandidate` takes JSON-encoded
`RTCIceCandidateInit`. This matches how every webrtc-rs signaling example does it, and
means your own signaling transport (a websocket, Discord's voice gateway, anything)
just shuttles opaque strings - no need to hand-mirror those structs into Dart.

### Events are real Dart sealed unions (freezed), not flattened structs

`PeerConnectionEvent` and `DataChannelEvent` are proper Rust enums with per-variant
data, generated into Dart via `freezed` (a flutter_rust_bridge dependency for this -
see `pubspec.yaml`'s `dev_dependencies`/`dependencies`). Pattern-match with Dart 3
switch expressions:

```dart
switch (event) {
  case PeerConnectionEvent_IceCandidate(:final candidateJson): ...
  case PeerConnectionEvent_RemoteTrack(:final trackId, :final kind): ...
  ...
}
```

**Whenever Rust-side types change, regenerate in this order** - skipping the second
step leaves `dart analyze`/the build failing on stale generated freezed classes that
look unrelated to what you changed:

```bash
flutter_rust_bridge_codegen generate
flutter pub run build_runner build
```

### Why peer-connection events are polled, not pushed straight into a `StreamSink`

flutter_rust_bridge cannot generate a function that both takes a `StreamSink` *and*
returns a meaningful value - it collapses such a function into a stream-only factory
and drops the return value from the generated bindings entirely. Since
`RtcPeerConnection::create` needs to return the constructed handle, event delivery is
split in two: `create()` buffers events into an internal channel from the moment the
connection exists, and a separate `events()` call drains that buffer into the
`StreamSink` whenever Dart gets around to subscribing - so nothing fires before
`events()` is a lost event. `RtcDataChannel::events`/`RtcRemoteTrack::packets` mirror
this shape for consistency even though they don't have the same constraint.

## Adding a platform

Only macOS has been build-tested (see Status). webrtc-rs's `rtc`/`webrtc` crates are
pure Rust with no native C/C++ dependency and no per-platform SDK to vendor, so adding
a target should mostly mean adding it to cargokit's platform list in `pubspec.yaml`
and to each `ios`/`android`/`linux`/`windows` folder's existing cargokit scaffold,
then working through whatever UDP-socket-entitlement equivalent that platform has
(see the macOS App Sandbox note above - Android will need the `INTERNET` permission
at minimum).
