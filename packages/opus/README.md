# opus

Dart/Flutter FFI bindings for [libopus](https://opus-codec.org/) (vendored
as a git submodule at `third_party/opus`), covering just the plain
encoder/decoder API needed for real-time voice chat.

## Status

- **macOS: working end-to-end.** `dart test` builds libopus from source via
  CMake and round-trips a real encode/decode.
- **iOS / Android / Linux / Windows: not yet implemented** - same situation
  as the `dave` package; `hook/build.dart` only handles `OS.macOS` and
  throws a clear error otherwise.
- Not yet wired into bonfire's voice controller.

## Project structure

Mirrors the `dave` package's layout and approach (same native-assets build
hook mechanism), but much simpler: libopus has no third-party dependencies,
so there's no vcpkg step - just a plain `cmake -B && cmake --build --target
install` of libopus's own CMakeLists.txt.

- `third_party/opus` - libopus, vendored as a git submodule
  (`git submodule update --init --recursive` after cloning).
- `ffigen.yaml` / `lib/src/opus_bindings_generated.dart` - bindings
  generated directly from `opus.h`. Regenerate with
  `dart run ffigen --config ffigen.yaml`.
- `hook/build.dart` - builds libopus and registers it as the
  `package:opus/opus` code asset.
- `lib/src/opus_codec.dart` - `OpusEncoder`/`OpusDecoder` wrapper (handle
  lifecycle via `dispose()` + a `NativeFinalizer` safety net, PCM/byte
  buffer marshalling). `lib/opus.dart` is the public barrel export.

## Building and testing

```bash
git submodule update --init --recursive   # first time only
cd packages/opus
dart test
```

## Usage sketch

```dart
final encoder = OpusEncoder(sampleRate: 48000, channels: 1);
final packet = encoder.encode(pcmFrame, frameSize: 960); // 20ms @ 48kHz
encoder.dispose();

final decoder = OpusDecoder(sampleRate: 48000, channels: 1);
final pcm = decoder.decode(packet, frameSize: 960);
// decoder.decode(null, frameSize: 960) for packet-loss concealment
decoder.dispose();
```

One `OpusDecoder` per remote participant/SSRC - decoder state (including
packet-loss concealment) is per-sender and shouldn't be shared.

## Adding another platform

Same approach as `dave`'s README describes, but simpler since there's no
vcpkg triplet to pick - just the right `cmake -B` invocation
(`CMAKE_TOOLCHAIN_FILE` for cross-compilation, e.g. the Android NDK's
`android.toolchain.cmake`) for the target OS/architecture in
`hook/build.dart`'s `_buildLibopus`.
