//! Local media senders and remote media track handles.
//!
//! Both sides are deliberately "dumb transport" as far as frame *content* goes:
//! [`RtcMediaSender::write_encoded_frame`] takes already-encoded bytes (an Opus
//! frame, an H264 Annex-B access unit, whatever codec you negotiated) and
//! packetizes+sends them; [`RtcRemoteTrack::packets`] hands back reassembled
//! encoded frames - depacketized per the track's negotiated codec (see
//! `depacketizer_for_mime_type` below), so a multi-packet H264 frame arrives as
//! one Annex-B buffer rather than requiring the caller to reassemble RTP
//! fragments by hand. Neither side inspects or transforms what's *inside* those
//! bytes.
//!
//! This whole-frame model is what makes DAVE (or any other frame-level E2EE)
//! integration free *for codecs where one encoded frame is always exactly one
//! RTP packet* - true for Opus, which is why `write_encoded_frame`/`packets`
//! work correctly for audio as-is. It is **not** true for H264: any frame
//! bigger than one MTU (~1200 bytes - true of nearly every real video frame,
//! confirmed live: encoded frames here run 6KB-190KB) gets fragmented across
//! many RTP packets.
//!
//! DAVE's own encryption granularity is the **whole encoded access unit**
//! (everything one call to the encoder produced - for a keyframe that's
//! SPS+PPS+IDR-slice together, for a delta frame just the one slice), not
//! the NAL unit and not the RTP packet. Confirmed directly from Discord's
//! own vendored `libdave` source (`packages/dave/third_party/libdave/cpp/
//! src/codec_utils.cpp`'s `ProcessFrameH264`): it loops over *every* NAL
//! unit found in the buffer it's given in one call, and `encryptor.cpp`'s
//! `Encrypt()` runs exactly one AES-GCM operation and appends exactly one
//! trailer (nonce/tag/unencrypted-ranges/marker) for that whole call - a
//! real peer's decryptor expects to find exactly one such trailer per
//! decrypted buffer, at its very end. Calling `encrypt()`/`decrypt()` once
//! per NAL (an earlier version of this module did exactly that, to work
//! around a *different*, RTP-fragment-granularity bug - see below) produces
//! several independently-tagged ciphertexts spliced together with no start
//! code separating a NAL's content from the previous NAL's trailer, which a
//! real, unmodified DAVE implementation elsewhere can never parse: it looks
//! self-consistent on a pure loopback test (this module's own send and
//! receive code agree with each other about the wrong framing) while being
//! silently incompatible with everyone else.
//!
//! (Encrypting RTP-*payload*-fragment-sized chunks, one level of granularity
//! finer still, is wrong for a different, cruder reason: DAVE's native H264
//! frame processor logs `"H264 frame is too small to contain a NAL unit"`
//! and rejects FU-A continuation fragments outright, since they carry no NAL
//! header of their own to inspect.)
//!
//! So the actual pipeline is: encrypt the whole plaintext encoded frame in
//! one call (SPS+PPS+slice(s) together, exactly as the encoder emitted it),
//! then hand the resulting ciphertext - still one coherent Annex-B buffer,
//! since DAVE always re-writes real start codes before whatever it leaves
//! unencrypted - to [`RtcMediaSender::write_packetized_frame`], which runs
//! the real H264 RTP payloader over it directly to fragment into actual
//! packets; the payloader only ever sees intact start codes and NAL headers,
//! exactly like a normal unencrypted frame, so it fragments correctly
//! regardless of what's inside. The mirror image applies on receive:
//! [`RtcRemoteTrack::raw_packets`] hands back undepacketized packets so
//! [`RtcH264Depacketizer`] can reassemble FU-A fragments *before* decryption
//! (reassembly is pure RTP-framing, needs no decryption) - the caller
//! accumulates every non-empty depacketized chunk across one whole access
//! unit (an access unit can depacketize as more than one chunk, e.g. an
//! SPS+PPS STAP-A plus a separately-fragmented slice) until the RTP marker
//! bit says the frame is complete, then decrypts the concatenated result
//! once, mirroring exactly how it was encrypted.
use std::sync::atomic::{AtomicU16, AtomicU32, AtomicU8, Ordering};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

use bytes::Bytes;
use flutter_rust_bridge::frb;
use crate::frb_generated::StreamSink;
use rtc::media::Sample;
use rtc::media_stream::MediaStreamTrack;
use rtc::peer_connection::configuration::media_engine::{MIME_TYPE_H264, MIME_TYPE_OPUS};
use rtc::rtp::codec::{h264::H264Packet, h264::H264Payloader, opus::OpusPacket};
use rtc::rtp::header::Header as RtpHeader;
use rtc::rtp::packet::Packet as RtpPacket;
use rtc::rtp::packetizer::{Depacketizer, Payloader};
use rtc::rtp_transceiver::rtp_sender::{
    RTCRtpCodec, RTCRtpCodingParameters, RTCRtpEncodingParameters,
};
use webrtc::media_stream::track_local::static_sample::TrackLocalStaticSample;
use webrtc::media_stream::track_local::TrackLocal;
use webrtc::media_stream::track_remote::{TrackRemote as WrtcTrackRemote, TrackRemoteEvent};
use webrtc::rtp_transceiver::RtpSender as WrtcRtpSender;

use crate::api::runtime_ctx::runtime;
use crate::api::types::{MediaKind, RemoteRtpPacket};

/// A local media track plus the RTP sender webrtc-rs allocated for it after
/// `add_track` (created via
/// [`crate::api::peer_connection::RtcPeerConnection::add_media_sender`]).
#[frb(opaque)]
pub struct RtcMediaSender {
    pub(crate) track: Arc<TrackLocalStaticSample>,
    pub(crate) sender: Arc<dyn WrtcRtpSender>,
    /// Fixed for this sender's whole lifetime - the SSRC baked into the
    /// track's coding parameters at creation time (see `build_local_track`).
    /// An earlier version of this made it mutable so a video sender could
    /// switch to a freshly-generated SSRC when the camera turned on
    /// (misreading real client traffic - see `startLocalVideo`'s doc in the
    /// main app for the full story); that was actively broken, not just
    /// unconfirmed: the underlying `rtc` crate's `RTCRtpSender::write_rtp`
    /// checks the packet's SSRC against `sender.track().ssrcs()` and
    /// silently drops (never even reaching the network) any packet whose
    /// SSRC isn't in that fixed set, which only ever contains this one.
    ssrc: u32,
    /// Resolved lazily: the payload type isn't known until after SDP negotiation
    /// assigns this sender's codec, which is why this isn't just a plain field.
    payload_type: AtomicU8,
    payload_type_resolved: std::sync::atomic::AtomicBool,
    /// Only used by [`payload_h264_frame`](Self::payload_h264_frame) - stateful
    /// across calls because a real payloader tracks SPS/PPS NALs seen so far
    /// (to prepend them ahead of the next keyframe's slice, via STAP-A).
    h264_payloader: Mutex<H264Payloader>,
    /// RTP sequence number and timestamp bookkeeping for
    /// [`write_packetized_frame`](Self::write_packetized_frame) - this sender
    /// owns both since it's the only writer of this track's packets, mirroring
    /// what `TrackLocalStaticSample`'s internal packetizer would otherwise do
    /// for us (bypassed here specifically to get per-packet payloads out for
    /// encryption before they're wrapped into `RtpPacket`s - see this module's
    /// doc for why).
    next_sequence_number: AtomicU16,
    running_timestamp: AtomicU32,
}

impl RtcMediaSender {
    pub(crate) fn new(track: Arc<TrackLocalStaticSample>, sender: Arc<dyn WrtcRtpSender>, ssrc: u32) -> Self {
        Self {
            track,
            sender,
            ssrc,
            payload_type: AtomicU8::new(0),
            payload_type_resolved: std::sync::atomic::AtomicBool::new(false),
            h264_payloader: Mutex::new(H264Payloader::default()),
            // Randomized starting points, matching normal RTP practice (RFC
            // 3550 §5.1) of not starting a stream's sequence number/timestamp
            // at a predictable value.
            next_sequence_number: AtomicU16::new(rand::random()),
            running_timestamp: AtomicU32::new(rand::random()),
        }
    }

    async fn resolve_payload_type(&self) -> Result<u8, String> {
        if self.payload_type_resolved.load(Ordering::Acquire) {
            return Ok(self.payload_type.load(Ordering::Acquire));
        }
        let params = self
            .sender
            .get_parameters()
            .await
            .map_err(|e| e.to_string())?;
        let payload_type = params
            .rtp_parameters
            .codecs
            .first()
            .map(|codec| codec.payload_type)
            .ok_or_else(|| "sender has no negotiated codec yet - wait for the offer/answer \
                             exchange to finish before sending"
                .to_string())?;
        self.payload_type.store(payload_type, Ordering::Release);
        self.payload_type_resolved.store(true, Ordering::Release);
        Ok(payload_type)
    }

    /// The RTP payload type this sender will actually stamp on outgoing
    /// packets, resolved from the negotiated SDP (same value
    /// [`write_encoded_frame`](Self::write_encoded_frame)/
    /// [`write_packetized_frame`](Self::write_packetized_frame) use
    /// internally). Exposed so callers can cross-check it against whatever
    /// payload type they told the remote peer to expect out-of-band (e.g. in
    /// `VoiceGateway.selectWebRtcProtocol`'s `codecs` array) - if those ever
    /// disagree, packets go out with a payload type the peer was never told
    /// about and just get silently ignored, with no error on either side to
    /// notice by.
    pub async fn resolved_payload_type(&self) -> Result<u8, String> {
        self.resolve_payload_type().await
    }

    /// Packetizes and sends one already-encoded frame (e.g. a DAVE-encrypted Opus
    /// payload). `duration_micros` is the frame's playout duration - 20000 for a
    /// standard 20ms Opus frame - which webrtc-rs uses to advance the RTP timestamp.
    pub async fn write_encoded_frame(&self, data: Vec<u8>, duration_micros: u64) -> Result<(), String> {
        let payload_type = self.resolve_payload_type().await?;
        self.track
            .sample_writer(self.ssrc, payload_type)
            .write_sample(&Sample {
                data: Bytes::from(data),
                duration: Duration::from_micros(duration_micros),
                ..Sample::new(Instant::now())
            })
            .await
            .map_err(|e| e.to_string())
    }

    /// Takes one already-encoded H264 Annex-B frame - the encoder's full
    /// output for one access unit (SPS+PPS+IDR-slice for a keyframe, just a
    /// slice for a delta frame), already transformed whole by the caller if
    /// desired (e.g. DAVE-encrypted - see this module's doc for why that
    /// must happen before this call, on the whole frame, not per-NAL) - runs
    /// the real H264 RTP payloader over it to fragment into RTP-payload-
    /// sized chunks, and sends the result as one frame's worth of RTP
    /// packets: sequence numbers assigned in order, the marker bit set only
    /// on the last packet, and the RTP timestamp advanced once for the whole
    /// frame by `duration_micros` at H264's fixed 90kHz clock rate (not once
    /// per packet - every packet here belongs to the same frame, so per RFC
    /// 3550 they share one timestamp).
    ///
    /// The payloader only ever sees intact start codes and NAL headers
    /// here - never partial/ciphertext-boundary-confused input - so it
    /// fragments exactly as it would a normal unencrypted frame, regardless
    /// of what DAVE put inside.
    ///
    /// `mtu` should leave headroom below the real network MTU for whatever
    /// the caller's encryption added (DAVE's overhead is small - a nonce, an
    /// auth tag, a few bookkeeping bytes - but some) plus SRTP's own
    /// per-packet overhead added later; 1000 is a reasonable default
    /// (matching this module's Dart caller).
    pub async fn write_packetized_frame(&self, data: Vec<u8>, mtu: usize, duration_micros: u64) -> Result<(), String> {
        if data.is_empty() {
            return Ok(());
        }

        let chunks = {
            let mut payloader = self.h264_payloader.lock().map_err(|_| "h264 payloader lock poisoned".to_string())?;
            payloader.payload(mtu, &Bytes::from(data)).map_err(|e| e.to_string())?
        };
        if chunks.is_empty() {
            return Ok(());
        }

        let payload_type = self.resolve_payload_type().await?;
        let ssrc = self.ssrc;
        let timestamp = self.running_timestamp.load(Ordering::Relaxed);
        let last_index = chunks.len() - 1;

        for (i, chunk) in chunks.into_iter().enumerate() {
            let sequence_number = self.next_sequence_number.fetch_add(1, Ordering::Relaxed);
            let packet = RtpPacket {
                header: RtpHeader {
                    version: 2,
                    marker: i == last_index,
                    payload_type,
                    sequence_number,
                    timestamp,
                    ssrc,
                    ..Default::default()
                },
                payload: chunk,
            };
            self.track.write_rtp(packet).await.map_err(|e| e.to_string())?;
        }

        // H264's RTP clock rate is fixed at 90kHz (see `clock_rate_and_channels`
        // below) - duration_micros * 90_000 / 1_000_000 converts wall-clock
        // microseconds to clock ticks.
        let timestamp_delta = ((duration_micros as u128 * 90_000) / 1_000_000) as u32;
        self.running_timestamp.fetch_add(timestamp_delta, Ordering::Relaxed);
        Ok(())
    }
}

/// Splits an already-encoded (and, for a real self-test, DAVE-encrypted)
/// H264 Annex-B frame into RTP-payload-sized chunks - exactly the transform
/// [`RtcMediaSender::write_packetized_frame`] applies before sending, but
/// returned instead of sent. Needs no live sender/peer connection, since
/// `H264Payloader` is a pure data transform - this exists purely so a
/// caller can verify a frame it's about to send is actually reconstructable
/// via [`RtcH264Depacketizer`] *without* a network round trip: encode,
/// encrypt (real DAVE), payloadize with this, depacketize+decrypt+decode
/// locally, and confirm a picture comes out. Useful because Discord's own
/// SFU never echoes a sender's own stream back to them, so that path can
/// otherwise only ever be exercised by a second real participant.
pub fn h264_payloadize_for_loopback_test(data: Vec<u8>, mtu: usize) -> Result<Vec<Vec<u8>>, String> {
    let mut payloader = H264Payloader::default();
    let chunks = payloader.payload(mtu, &Bytes::from(data)).map_err(|e| e.to_string())?;
    Ok(chunks.into_iter().map(|b| b.to_vec()).collect())
}

/// A remote media track, handed back from
/// [`crate::api::peer_connection::RtcPeerConnection::take_remote_track`] after a
/// [`crate::api::types::PeerConnectionEvent::RemoteTrack`] event.
#[frb(opaque)]
pub struct RtcRemoteTrack {
    pub(crate) inner: Arc<dyn WrtcTrackRemote>,
}

impl RtcRemoteTrack {
    pub async fn kind(&self) -> MediaKind {
        self.inner.kind().await.into()
    }

    pub async fn mime_type(&self) -> Option<String> {
        let ssrc = self.inner.ssrcs().await.first().copied()?;
        self.inner.codec(ssrc).await.map(|c| c.mime_type)
    }

    /// Subscribes to this track's inbound frames, reassembled from RTP packets
    /// per the track's negotiated codec (see `depacketizer_for_mime_type`) -
    /// spawns a poll loop for the lifetime of the track, so subscribe once per
    /// track. A multi-packet H264 access unit (near-universal for anything but
    /// the smallest frames) arrives as a single [`RemoteRtpPacket::payload`]
    /// once its last fragment lands, not as separate fragments the caller has
    /// to reassemble; intermediate fragments produce no event at all.
    ///
    /// `sequence_number`/`timestamp`/`marker` on the emitted [`RemoteRtpPacket`]
    /// are the *last* RTP packet's - i.e. the one that completed the frame.
    pub async fn packets(&self, sink: StreamSink<RemoteRtpPacket>) {
        let inner = Arc::clone(&self.inner);
        let ssrc = inner.ssrcs().await.first().copied();
        let mime_type = match ssrc {
            Some(ssrc) => inner.codec(ssrc).await.map(|c| c.mime_type),
            None => None,
        };
        let mut depacketizer = depacketizer_for_mime_type(mime_type.as_deref());

        runtime().spawn(Box::pin(async move {
            while let Some(event) = inner.poll().await {
                let TrackRemoteEvent::OnRtpPacket(packet) = event else {
                    continue;
                };
                let payload = match depacketizer.depacketize(&packet.payload) {
                    Ok(bytes) => bytes,
                    Err(_) => continue, // malformed fragment - drop it, wait for the next keyframe/packet
                };
                // Empty means "fragment buffered, frame not complete yet" (e.g. a
                // non-final H264 FU-A piece) - nothing to emit.
                if payload.is_empty() {
                    continue;
                }
                let frame = RemoteRtpPacket {
                    payload: payload.to_vec(),
                    sequence_number: packet.header.sequence_number,
                    timestamp: packet.header.timestamp,
                    ssrc: packet.header.ssrc,
                    marker: packet.header.marker,
                };
                if sink.add(frame).is_err() {
                    break;
                }
            }
        }));
    }

    /// As [`packets`](Self::packets), but yields **raw** RTP packet payloads
    /// with no depacketization/reassembly - one event per RTP packet
    /// received, not per completed frame. Needed for DAVE (or any other
    /// frame-level transform - see this module's doc): feed each packet from
    /// this stream through a [`RtcH264Depacketizer`] first (reassembly is
    /// pure RTP framing and needs no decryption), accumulate its non-empty
    /// results across one whole access unit, and only decrypt once the RTP
    /// marker bit says that access unit is complete. Using
    /// [`packets`](Self::packets) instead and decrypting only the fully-
    /// reassembled result doesn't work: its `H264Packet` depacketizer needs
    /// to see real (already-decrypted) NAL/FU-A structure to find fragment
    /// boundaries, and just drops every still-encrypted packet as
    /// unparseable.
    pub async fn raw_packets(&self, sink: StreamSink<RemoteRtpPacket>) {
        let inner = Arc::clone(&self.inner);
        runtime().spawn(Box::pin(async move {
            while let Some(event) = inner.poll().await {
                let TrackRemoteEvent::OnRtpPacket(packet) = event else {
                    continue;
                };
                let frame = RemoteRtpPacket {
                    payload: packet.payload.to_vec(),
                    sequence_number: packet.header.sequence_number,
                    timestamp: packet.header.timestamp,
                    ssrc: packet.header.ssrc,
                    marker: packet.header.marker,
                };
                if sink.add(frame).is_err() {
                    break;
                }
            }
        }));
    }
}

/// The per-packet counterpart to [`RtcRemoteTrack::raw_packets`] - reassembles
/// H264 RTP packet payloads (each already decrypted by the caller, e.g. via
/// DAVE) back into Annex-B frames. One instance holds the FU-A reassembly
/// state for a single remote sender's video stream - see this module's doc
/// for why this exists instead of just using [`RtcRemoteTrack::packets`].
#[frb(opaque)]
pub struct RtcH264Depacketizer {
    inner: Mutex<H264Packet>,
}

impl RtcH264Depacketizer {
    pub fn create() -> RtcH264Depacketizer {
        RtcH264Depacketizer { inner: Mutex::new(H264Packet::default()) }
    }

    /// Feeds one **still-encrypted** raw RTP packet payload in, in arrival
    /// order - reassembly is pure RTP framing (FU-A/STAP-A), so it needs no
    /// decryption first, only decrypting *after* is correct (see this
    /// module's doc). Returns an empty buffer for every fragment before the
    /// one that completes a NAL (a non-final H264 FU-A piece, say) - not an
    /// error, just "not done yet". Returns a non-empty Annex-B buffer once a
    /// NAL (or, for a STAP-A packet, more than one) is complete - the caller
    /// should concatenate every non-empty result across one whole access
    /// unit (using the RTP packet's own marker bit to know when that access
    /// unit is done) and decrypt the concatenation once, mirroring how the
    /// sender encrypted the whole access unit in one call (see this
    /// module's doc).
    pub fn depacketize(&self, data: Vec<u8>) -> Result<Vec<u8>, String> {
        let mut inner = self.inner.lock().map_err(|_| "RtcH264Depacketizer: lock poisoned".to_string())?;
        let bytes = inner.depacketize(&Bytes::from(data)).map_err(|e| e.to_string())?;
        Ok(bytes.to_vec())
    }
}

/// Picks the RTP depacketizer matching a negotiated codec's mime type -
/// mirrors `RTCRtpCodec::payloader` (the sending-side equivalent, in the `rtc`
/// crate itself) but there's no built-in receiving-side counterpart to call
/// into, so this hand-rolls the same mapping for the codecs this crate cares
/// about today. Anything else (VP8/VP9/AV1/H265, or an unknown mime type -
/// including `None`, which happens if a track's SSRC/codec isn't resolvable
/// yet) falls back to passing packets through unchanged, i.e. today's
/// behavior for every codec other than H264: correct for codecs that never
/// fragment a frame across multiple packets (Opus explicitly, via
/// `OpusPacket`, and everything else by the passthrough default, which is
/// only actually *correct* for non-fragmenting traffic), a silent
/// reassembly gap for ones that do.
fn depacketizer_for_mime_type(mime_type: Option<&str>) -> Box<dyn Depacketizer + Send> {
    struct Passthrough;
    impl Depacketizer for Passthrough {
        fn depacketize(&mut self, b: &Bytes) -> rtc::shared::error::Result<Bytes> {
            Ok(b.clone())
        }
        fn is_partition_head(&self, _payload: &Bytes) -> bool {
            true
        }
        fn is_partition_tail(&self, marker: bool, _payload: &Bytes) -> bool {
            marker
        }
    }

    match mime_type {
        Some(mime) if mime.eq_ignore_ascii_case(MIME_TYPE_H264) => {
            Box::new(H264Packet::default())
        }
        Some(mime) if mime.eq_ignore_ascii_case(MIME_TYPE_OPUS) => Box::new(OpusPacket),
        _ => Box::new(Passthrough),
    }
}

/// Builds the local track + encoding parameters for `add_track`. Kept free of
/// `RtcPeerConnection` so it can be unit-tested / reused without a live connection.
pub(crate) fn build_local_track(
    kind: MediaKind,
    mime_type: String,
    ssrc: u32,
    stream_id: String,
    track_id: String,
) -> Result<Arc<TrackLocalStaticSample>, String> {
    // `TrackLocalStaticSample::new` only builds a packetizer for an SSRC whose
    // `RTCRtpEncodingParameters.codec` resolves to a real payloader (see its source:
    // it looks up `track.codec(ssrc)` and silently skips the SSRC if that's `None`) -
    // `write_sample`/`sample_writer` then fail with "codec not found" for that SSRC.
    // So this *must* carry a real codec, not `Default::default()`; clock rate/channels
    // are RFC-fixed per mime type (Opus is always 48 kHz/2ch, every video codec here is
    // 90 kHz), which is also what `MediaEngine::register_default_codecs` uses, so
    // hardcoding them here rather than threading them through the public API is safe.
    let (clock_rate, channels) = clock_rate_and_channels(&mime_type);
    let codec = RTCRtpCodec {
        mime_type,
        clock_rate,
        channels,
        sdp_fmtp_line: String::new(),
        rtcp_feedback: Vec::new(),
    };
    let coding = RTCRtpEncodingParameters {
        rtp_coding_parameters: RTCRtpCodingParameters {
            ssrc: Some(ssrc),
            ..Default::default()
        },
        codec,
        ..Default::default()
    };
    let media_track = MediaStreamTrack::new(
        stream_id,
        track_id.clone(),
        track_id,
        kind.into(),
        vec![coding],
    );
    Ok(Arc::new(
        TrackLocalStaticSample::new(Instant::now(), media_track).map_err(|e| e.to_string())?,
    ))
}

/// RFC-fixed clock rate (Hz) and channel count for the mime types
/// `MediaEngine::register_default_codecs` registers. Falls back to the video default
/// (90 kHz, no channel count) for anything unrecognized, since every non-Opus codec
/// this crate's `MediaEngine` knows about uses that.
fn clock_rate_and_channels(mime_type: &str) -> (u32, u16) {
    if mime_type.eq_ignore_ascii_case(rtc::peer_connection::configuration::media_engine::MIME_TYPE_OPUS) {
        (48_000, 2)
    } else {
        (90_000, 0)
    }
}

/// Exposed so `add_track` in `peer_connection.rs` can hand the concrete track type to
/// webrtc-rs's `Arc<dyn TrackLocal>`-typed API without duplicating the cast site.
pub(crate) fn as_track_local(track: &Arc<TrackLocalStaticSample>) -> Arc<dyn TrackLocal> {
    Arc::clone(track) as Arc<dyn TrackLocal>
}

// Unit test, not a `tests/*.rs` integration test - see video_codec.rs's tests
// module doc for why (this crate only builds cdylib/staticlib, no rlib).
#[cfg(test)]
mod h264_packetization_tests {
    use super::*;
    use crate::api::video_codec::{H264Decoder, H264Encoder};

    const WIDTH: u32 = 320;
    const HEIGHT: u32 = 240;

    fn solid_bgra_frame(width: u32, height: u32, b: u8, g: u8, r: u8) -> Vec<u8> {
        let mut data = Vec::with_capacity((width * height * 4) as usize);
        for _ in 0..(width * height) {
            data.extend_from_slice(&[b, g, r, 255]);
        }
        data
    }

    /// Validates the *actual* pipeline this module's doc describes -
    /// whole-access-unit encryption granularity, not per-NAL and not
    /// per-RTP-fragment (an earlier version of this test validated a
    /// per-NAL scheme that turned out to be wrong: self-consistent in a
    /// loopback test, but incompatible with Discord's real DAVE
    /// implementation - see this module's doc). Encodes a frame, applies a
    /// stand-in "encrypt" to the *whole* encoder output in one call (real
    /// DAVE isn't available in a unit test, but any transform applied once
    /// per whole frame exercises the same accumulate-until-marker path),
    /// payloadizes exactly as `write_packetized_frame` does, depacketizes,
    /// accumulates every non-empty depacketized chunk across the access
    /// unit (mirroring what a caller does using the RTP marker bit - here
    /// simply "every chunk from this one `payload()` call belongs to the
    /// same frame"), "decrypts" the concatenation once, and confirms the
    /// decoder still produces a real picture. Independent of any live RTP
    /// transport (`tests/webrtc_loopback.rs` covers that separately).
    ///
    /// Uses a small MTU deliberately, to force genuine multi-packet
    /// fragmentation rather than accidentally fitting the whole frame in
    /// one packet.
    #[test]
    fn encrypt_packetize_reassemble_h264_frame_stays_decodable() {
        // Stand-in for DAVE: reversible, and - like DAVE - changes the
        // frame's length, so a test that accidentally assumed a fixed size
        // wouldn't catch a bug that only shows up when sizes shift.
        fn fake_encrypt(frame: &[u8]) -> Vec<u8> {
            let mut out = frame.to_vec();
            out.push(0xAA);
            out
        }
        fn fake_decrypt(frame: &[u8]) -> Vec<u8> {
            frame[..frame.len() - 1].to_vec()
        }

        let encoder = H264Encoder::create(1_000_000).expect("create encoder");
        let decoder = H264Decoder::create().expect("create decoder");
        let frame = solid_bgra_frame(WIDTH, HEIGHT, 20, 40, 200);

        let mut payloader = H264Payloader::default();
        let mut depacketizer = H264Packet::default();
        let mtu = 100; // deliberately small - forces FU-A fragmentation

        let mut decoded = None;
        'encode_loop: for _ in 0..5 {
            let encoded = encoder.encode_bgra8(frame.clone(), WIDTH, HEIGHT).expect("encode_bgra8");
            let encrypted = fake_encrypt(&encoded);

            let chunks = payloader.payload(mtu, &Bytes::from(encrypted)).expect("payload");
            assert!(
                chunks.len() > 1,
                "expected fragmentation with a {mtu}-byte MTU, got {} chunk(s)",
                chunks.len()
            );

            let mut accumulated = Vec::new();
            for chunk in chunks {
                let depacketized = depacketizer.depacketize(&chunk).expect("depacketize");
                if !depacketized.is_empty() {
                    accumulated.extend_from_slice(&depacketized);
                }
            }
            if accumulated.is_empty() {
                continue;
            }

            let plaintext = fake_decrypt(&accumulated);
            if let Some(frame) = decoder.decode(plaintext).expect("decode") {
                decoded = Some(frame);
                break 'encode_loop;
            }
        }

        let decoded = decoded.expect("decoder never produced a picture across 5 encoded frames");
        assert_eq!(decoded.width, WIDTH);
        assert_eq!(decoded.height, HEIGHT);
    }
}
