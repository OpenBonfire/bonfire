//! Plain data types that cross the Dart boundary.
//!
//! SDP and ICE candidates deliberately do NOT get dedicated mirrored types here -
//! they cross as JSON strings (`serde_json::to_string`/`from_str` on webrtc-rs's own
//! `RTCSessionDescription` / `RTCIceCandidateInit`, which already derive
//! `Serialize`/`Deserialize`). That is exactly how every webrtc-rs signaling example
//! exchanges them, it means Dart-side signaling code just shuttles opaque JSON
//! strings to whatever transport you use (a websocket, Discord's voice gateway,
//! anything), and it avoids hand-mirroring two large, semver-fragile structs.
//!
//! The connection/gathering/signaling-state enums below, and the two event enums,
//! ARE mirrored 1:1 as real Dart sealed unions (flutter_rust_bridge generates these
//! via `freezed` - see the `dev_dependencies` this package declares), because callers
//! branch/pattern-match on them directly and a flattened struct would be a worse Dart
//! API for that.

use webrtc::data_channel::DataChannelEvent as WrtcDataChannelEvent;
use webrtc::peer_connection::{
    RTCIceConnectionState, RTCIceGatheringState, RTCPeerConnectionState, RTCSignalingState,
};
use rtc::rtp_transceiver::rtp_sender::RtpCodecKind as WrtcMediaKind;

/// One ICE/STUN/TURN server, mirroring [`webrtc::peer_connection::RTCIceServer`].
#[derive(Debug, Clone)]
pub struct IceServer {
    pub urls: Vec<String>,
    pub username: String,
    pub credential: String,
}

/// Configuration for [`crate::api::peer_connection::RtcPeerConnection::create`].
#[derive(Debug, Clone)]
pub struct RtcConfig {
    pub ice_servers: Vec<IceServer>,
    /// Local `host:port` addresses to bind UDP sockets on and gather ICE host
    /// candidates from - `"0.0.0.0:0"` (bind an ephemeral port on every interface,
    /// the default) is almost always right for a real call. Override this to
    /// restrict which interfaces are used, or (the reason this is here rather than
    /// hardcoded) to force same-host loopback for testing: some sandboxed/
    /// containerized networks don't hairpin traffic a process sends to its own
    /// LAN-facing address back to itself, which reads as ICE connectivity checks
    /// hanging forever at `IceConnectionState.checking` even though both peers are
    /// on the same machine - binding both sides to `"127.0.0.1:0"` sidesteps that.
    pub udp_bind_addrs: Vec<String>,
}

impl Default for RtcConfig {
    fn default() -> Self {
        Self {
            ice_servers: Vec::new(),
            udp_bind_addrs: vec!["0.0.0.0:0".to_string()],
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MediaKind {
    Audio,
    Video,
}

impl From<WrtcMediaKind> for MediaKind {
    fn from(kind: WrtcMediaKind) -> Self {
        match kind {
            WrtcMediaKind::Video => MediaKind::Video,
            // `RtpCodecKind` is audio/video only upstream; anything else (there is
            // nothing else today) falls back to audio rather than panicking.
            _ => MediaKind::Audio,
        }
    }
}

impl From<MediaKind> for WrtcMediaKind {
    fn from(kind: MediaKind) -> Self {
        match kind {
            MediaKind::Audio => WrtcMediaKind::Audio,
            MediaKind::Video => WrtcMediaKind::Video,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PeerConnectionState {
    New,
    Connecting,
    Connected,
    Disconnected,
    Failed,
    Closed,
}

impl From<RTCPeerConnectionState> for PeerConnectionState {
    fn from(state: RTCPeerConnectionState) -> Self {
        match state {
            RTCPeerConnectionState::New => Self::New,
            RTCPeerConnectionState::Connecting => Self::Connecting,
            RTCPeerConnectionState::Connected => Self::Connected,
            RTCPeerConnectionState::Disconnected => Self::Disconnected,
            RTCPeerConnectionState::Failed => Self::Failed,
            RTCPeerConnectionState::Closed => Self::Closed,
            // Non-exhaustive upstream enum: treat anything future/unknown as a no-op
            // "still new" rather than failing to compile on their next release.
            _ => Self::New,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum IceGatheringState {
    New,
    Gathering,
    Complete,
}

impl From<RTCIceGatheringState> for IceGatheringState {
    fn from(state: RTCIceGatheringState) -> Self {
        match state {
            RTCIceGatheringState::New => Self::New,
            RTCIceGatheringState::Gathering => Self::Gathering,
            RTCIceGatheringState::Complete => Self::Complete,
            _ => Self::New,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum IceConnectionState {
    New,
    Checking,
    Connected,
    Completed,
    Disconnected,
    Failed,
    Closed,
}

impl From<RTCIceConnectionState> for IceConnectionState {
    fn from(state: RTCIceConnectionState) -> Self {
        match state {
            RTCIceConnectionState::New => Self::New,
            RTCIceConnectionState::Checking => Self::Checking,
            RTCIceConnectionState::Connected => Self::Connected,
            RTCIceConnectionState::Completed => Self::Completed,
            RTCIceConnectionState::Disconnected => Self::Disconnected,
            RTCIceConnectionState::Failed => Self::Failed,
            RTCIceConnectionState::Closed => Self::Closed,
            _ => Self::New,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SignalingState {
    Stable,
    HaveLocalOffer,
    HaveRemoteOffer,
    HaveLocalPranswer,
    HaveRemotePranswer,
    Closed,
}

impl From<RTCSignalingState> for SignalingState {
    fn from(state: RTCSignalingState) -> Self {
        match state {
            RTCSignalingState::Stable => Self::Stable,
            RTCSignalingState::HaveLocalOffer => Self::HaveLocalOffer,
            RTCSignalingState::HaveRemoteOffer => Self::HaveRemoteOffer,
            RTCSignalingState::HaveLocalPranswer => Self::HaveLocalPranswer,
            RTCSignalingState::HaveRemotePranswer => Self::HaveRemotePranswer,
            RTCSignalingState::Closed => Self::Closed,
            _ => Self::Stable,
        }
    }
}

/// Top-level events from an [`crate::api::peer_connection::RtcPeerConnection`].
/// Subscribe via `RtcPeerConnection::events`. A real Dart sealed union (via freezed) -
/// switch on it directly.
#[derive(Debug, Clone)]
pub enum PeerConnectionEvent {
    ConnectionStateChanged(PeerConnectionState),
    IceGatheringStateChanged(IceGatheringState),
    IceConnectionStateChanged(IceConnectionState),
    SignalingStateChanged(SignalingState),
    /// A local ICE candidate was gathered - its JSON (an `RTCIceCandidateInit`).
    /// Forward it to the remote peer over your own signaling channel. There is no
    /// separate "end of candidates" event: watch for `IceGatheringStateChanged`
    /// reaching `IceGatheringState::Complete` instead.
    IceCandidate { candidate_json: String },
    /// The remote peer created a data channel in-band. Fetch a handle with
    /// `RtcPeerConnection::take_remote_data_channel(channel_id)`.
    DataChannel { channel_id: String },
    /// A remote media track became available. Fetch a handle with
    /// `RtcPeerConnection::take_remote_track(track_id)`.
    RemoteTrack { track_id: String, kind: MediaKind, mime_type: String },
    /// The local description needs to be renegotiated (e.g. after `add_media_sender`).
    NegotiationNeeded,
}

/// One data channel event, mirroring [`webrtc::data_channel::DataChannelEvent`].
#[derive(Debug, Clone)]
pub enum DataChannelEvent {
    Open,
    Message { data: Vec<u8>, is_text: bool },
    Closing,
    Closed,
    Error,
    /// Buffered-amount watermark events, kept only so `poll()`'s full event set is
    /// representable - most callers can ignore both.
    BufferedAmountLow,
    BufferedAmountHigh,
}

impl From<WrtcDataChannelEvent> for DataChannelEvent {
    fn from(event: WrtcDataChannelEvent) -> Self {
        match event {
            WrtcDataChannelEvent::OnOpen => Self::Open,
            WrtcDataChannelEvent::OnMessage(msg) => Self::Message {
                data: msg.data.to_vec(),
                is_text: msg.is_string,
            },
            WrtcDataChannelEvent::OnClosing => Self::Closing,
            WrtcDataChannelEvent::OnClose => Self::Closed,
            WrtcDataChannelEvent::OnError => Self::Error,
            WrtcDataChannelEvent::OnBufferedAmountLow => Self::BufferedAmountLow,
            _ => Self::BufferedAmountHigh,
        }
    }
}

/// One inbound RTP packet's payload for a subscribed remote track.
///
/// The payload is exactly the bytes the sender put on the wire for this packet - if
/// the caller is running DAVE (or any other frame-level scheme) on top, it is still
/// encrypted here. This layer never inspects payload contents; decrypt it, then feed
/// it to your decoder (Opus, VP8, ...) keyed off `sequence_number`/`timestamp` as
/// usual. Reassembly/reordering below the packet level (e.g. multi-packet video
/// frames) is not done by this layer - see the crate README.
#[derive(Debug, Clone)]
pub struct RemoteRtpPacket {
    pub payload: Vec<u8>,
    pub sequence_number: u16,
    pub timestamp: u32,
    pub ssrc: u32,
    pub marker: bool,
}
