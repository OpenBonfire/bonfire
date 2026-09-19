//! Local media senders and remote media track handles.
//!
//! Both sides are deliberately "dumb transport": [`RtcMediaSender::write_encoded_frame`]
//! takes already-encoded bytes (an Opus frame, a VP8/H264 frame, whatever codec you
//! negotiated) and packetizes+sends them; [`RtcRemoteTrack::packets`] hands back
//! already-depacketized RTP payload bytes exactly as they arrived. Neither side
//! encodes, decodes, or inspects payload contents.
//!
//! This is what makes DAVE (or any other frame-level E2EE) integration free: encrypt
//! the encoded frame before calling `write_encoded_frame`, decrypt the payload you get
//! from `packets` before handing it to your decoder. Nothing in this layer needs to
//! know that happened.
use std::sync::atomic::{AtomicU8, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use bytes::Bytes;
use flutter_rust_bridge::frb;
use crate::frb_generated::StreamSink;
use rtc::media::Sample;
use rtc::media_stream::MediaStreamTrack;
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
    pub(crate) ssrc: u32,
    /// Resolved lazily: the payload type isn't known until after SDP negotiation
    /// assigns this sender's codec, which is why this isn't just a plain field.
    payload_type: AtomicU8,
    payload_type_resolved: std::sync::atomic::AtomicBool,
}

impl RtcMediaSender {
    pub(crate) fn new(track: Arc<TrackLocalStaticSample>, sender: Arc<dyn WrtcRtpSender>, ssrc: u32) -> Self {
        Self {
            track,
            sender,
            ssrc,
            payload_type: AtomicU8::new(0),
            payload_type_resolved: std::sync::atomic::AtomicBool::new(false),
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

    /// Subscribes to this track's inbound RTP packets. Spawns a poll loop for the
    /// lifetime of the track - subscribe once per track.
    pub async fn packets(&self, sink: StreamSink<RemoteRtpPacket>) {
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
