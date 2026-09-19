//! [`RtcPeerConnection`]: the main entry point.
//!
//! SDP offers/answers and trickle ICE candidates cross the Dart boundary as JSON
//! strings (see `types.rs`'s module doc for why); everything else is a typed
//! method/event.
use std::collections::HashMap;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;

use flutter_rust_bridge::frb;
use crate::frb_generated::StreamSink;
use rtc::interceptor::Registry;
use rtc::peer_connection::configuration::interceptor_registry::register_default_interceptors;
use rtc::peer_connection::configuration::media_engine::MediaEngine;
use rtc::peer_connection::configuration::RTCConfigurationBuilder;
use rtc::peer_connection::transport::RTCIceCandidateInit;
use tokio::sync::{mpsc, Mutex as AsyncMutex};
use webrtc::data_channel::DataChannel as WrtcDataChannel;
use webrtc::media_stream::track_remote::TrackRemote as WrtcTrackRemote;
use webrtc::peer_connection::{
    PeerConnection as WrtcPeerConnection, PeerConnectionBuilder, PeerConnectionEventHandler,
    RTCIceConnectionState, RTCIceGatheringState, RTCIceServer, RTCPeerConnectionIceEvent,
    RTCPeerConnectionState, RTCSessionDescription, RTCSignalingState,
};

use crate::api::data_channel::RtcDataChannel;
use crate::api::media::{self, RtcMediaSender, RtcRemoteTrack};
use crate::api::runtime_ctx::runtime;
use crate::api::types::{MediaKind, PeerConnectionEvent, RtcConfig};

/// Shared state the event handler and the public [`RtcPeerConnection`] methods both
/// need - split out so it can be constructed before the handler (which the
/// `PeerConnectionBuilder` needs) while the `PeerConnection` itself (which the
/// handler does *not* need) is only available after `build()` returns.
///
/// Events are buffered into `event_tx`/`event_rx` rather than pushed straight into a
/// `StreamSink` for a load-bearing reason, not just symmetry with `RtcDataChannel`:
/// flutter_rust_bridge does not support a function that both takes a `StreamSink` and
/// returns a value - it collapses such a function into a plain
/// `static Stream<PeerConnectionEvent> create(...)` factory on the Dart side and
/// silently drops the constructed `RtcPeerConnection` from the generated bindings, so
/// there would be no way to get a handle back at all. Buffering internally decouples
/// "the connection exists and may already be emitting events" (true from the moment
/// `build()` returns) from "Dart has called `events()` and started reading" (which
/// can happen any time after `create()` returns) - exactly like webrtc-rs's own
/// `DataChannel::poll()`/`TrackRemote::poll()`, which this mirrors.
struct Shared {
    remote_tracks: AsyncMutex<HashMap<String, Arc<dyn WrtcTrackRemote>>>,
    remote_data_channels: AsyncMutex<HashMap<String, Arc<dyn WrtcDataChannel>>>,
    next_id: AtomicU64,
    event_tx: mpsc::UnboundedSender<PeerConnectionEvent>,
    event_rx: AsyncMutex<Option<mpsc::UnboundedReceiver<PeerConnectionEvent>>>,
}

impl Shared {
    fn new() -> Self {
        let (event_tx, event_rx) = mpsc::unbounded_channel();
        Self {
            remote_tracks: AsyncMutex::new(HashMap::new()),
            remote_data_channels: AsyncMutex::new(HashMap::new()),
            next_id: AtomicU64::new(0),
            event_tx,
            event_rx: AsyncMutex::new(Some(event_rx)),
        }
    }

    fn fresh_id(&self, prefix: &str) -> String {
        format!("{prefix}-{}", self.next_id.fetch_add(1, Ordering::Relaxed))
    }
}

struct Handler {
    shared: Arc<Shared>,
}

impl Handler {
    fn emit(&self, event: PeerConnectionEvent) {
        // Only fails if every receiver (there is at most one - see `events`) has
        // been dropped, i.e. nobody is listening or ever will again; dropping the
        // event on the floor is correct in that case.
        let _ = self.shared.event_tx.send(event);
    }
}

#[async_trait::async_trait]
impl PeerConnectionEventHandler for Handler {
    async fn on_negotiation_needed(&self) {
        self.emit(PeerConnectionEvent::NegotiationNeeded);
    }

    async fn on_ice_candidate(&self, event: RTCPeerConnectionIceEvent) {
        let Some(candidate_json) = event
            .candidate
            .to_json()
            .ok()
            .and_then(|init| serde_json::to_string(&init).ok())
        else {
            return;
        };
        self.emit(PeerConnectionEvent::IceCandidate { candidate_json });
    }

    async fn on_signaling_state_change(&self, state: RTCSignalingState) {
        self.emit(PeerConnectionEvent::SignalingStateChanged(state.into()));
    }

    async fn on_ice_connection_state_change(&self, state: RTCIceConnectionState) {
        self.emit(PeerConnectionEvent::IceConnectionStateChanged(state.into()));
    }

    async fn on_ice_gathering_state_change(&self, state: RTCIceGatheringState) {
        self.emit(PeerConnectionEvent::IceGatheringStateChanged(state.into()));
    }

    async fn on_connection_state_change(&self, state: RTCPeerConnectionState) {
        self.emit(PeerConnectionEvent::ConnectionStateChanged(state.into()));
    }

    async fn on_data_channel(&self, dc: Arc<dyn WrtcDataChannel>) {
        let channel_id = self.shared.fresh_id("dc");
        self.shared
            .remote_data_channels
            .lock()
            .await
            .insert(channel_id.clone(), dc);
        self.emit(PeerConnectionEvent::DataChannel { channel_id });
    }

    async fn on_track(&self, track: Arc<dyn WrtcTrackRemote>) {
        let kind: MediaKind = track.kind().await.into();
        let ssrc = track.ssrcs().await.first().copied().unwrap_or(0);
        let mime_type = track
            .codec(ssrc)
            .await
            .map(|c| c.mime_type)
            .unwrap_or_default();
        let track_id = self.shared.fresh_id("track");
        self.shared
            .remote_tracks
            .lock()
            .await
            .insert(track_id.clone(), track);
        self.emit(PeerConnectionEvent::RemoteTrack {
            track_id,
            kind,
            mime_type,
        });
    }
}

#[frb(opaque)]
pub struct RtcPeerConnection {
    inner: Arc<dyn WrtcPeerConnection>,
    shared: Arc<Shared>,
}

impl RtcPeerConnection {
    /// Creates a new connection and starts it gathering ICE candidates immediately
    /// (an implicit offer/answer role isn't chosen yet - call [`create_offer`] or
    /// feed it a remote offer via [`set_remote_description`] + [`create_answer`]).
    ///
    /// Call [`events`](Self::events) to subscribe to this connection's
    /// [`PeerConnectionEvent`]s - events fired before that call are buffered, not
    /// lost, so there's no race with early ICE candidates/state changes.
    pub async fn create(config: RtcConfig) -> Result<RtcPeerConnection, String> {
        let mut media_engine = MediaEngine::default();
        media_engine
            .register_default_codecs()
            .map_err(|e| e.to_string())?;
        let registry = register_default_interceptors(Registry::new(), &mut media_engine)
            .map_err(|e| e.to_string())?;

        let ice_servers = config
            .ice_servers
            .into_iter()
            .map(|s| RTCIceServer {
                urls: s.urls,
                username: s.username,
                credential: s.credential,
            })
            .collect();
        let rtc_config = RTCConfigurationBuilder::new()
            .with_ice_servers(ice_servers)
            .build();

        let shared = Arc::new(Shared::new());
        let handler = Arc::new(Handler { shared: Arc::clone(&shared) });

        let pc = PeerConnectionBuilder::new()
            .with_configuration(rtc_config)
            .with_media_engine(media_engine)
            .with_interceptor_registry(registry)
            .with_handler(handler)
            .with_runtime(runtime())
            .with_udp_addrs(config.udp_bind_addrs)
            .build()
            .await
            .map_err(|e| e.to_string())?;
        let inner: Arc<dyn WrtcPeerConnection> = Arc::new(pc);

        Ok(RtcPeerConnection { inner, shared })
    }

    /// Subscribes to this connection's events, including any fired before this call
    /// (see [`create`](Self::create)). Call at most once - a second call gets a
    /// stream that never emits anything, since the internal buffer has already been
    /// handed to the first caller.
    pub async fn events(&self, sink: StreamSink<PeerConnectionEvent>) {
        let shared = Arc::clone(&self.shared);
        runtime().spawn(Box::pin(async move {
            let Some(mut rx) = shared.event_rx.lock().await.take() else {
                return;
            };
            while let Some(event) = rx.recv().await {
                if sink.add(event).is_err() {
                    break;
                }
            }
        }));
    }

    /// Creates an SDP offer, JSON-encoded (an `RTCSessionDescription`).
    pub async fn create_offer(&self) -> Result<String, String> {
        let offer = self
            .inner
            .create_offer(None)
            .await
            .map_err(|e| e.to_string())?;
        serde_json::to_string(&offer).map_err(|e| e.to_string())
    }

    /// Creates an SDP answer (call after `set_remote_description` with a remote
    /// offer), JSON-encoded.
    pub async fn create_answer(&self) -> Result<String, String> {
        let answer = self
            .inner
            .create_answer(None)
            .await
            .map_err(|e| e.to_string())?;
        serde_json::to_string(&answer).map_err(|e| e.to_string())
    }

    /// `description_json` is a JSON-encoded `RTCSessionDescription` (as produced by
    /// `create_offer`/`create_answer` on either this connection or the remote peer).
    pub async fn set_local_description(&self, description_json: String) -> Result<(), String> {
        let desc: RTCSessionDescription =
            serde_json::from_str(&description_json).map_err(|e| e.to_string())?;
        self.inner
            .set_local_description(desc)
            .await
            .map_err(|e| e.to_string())
    }

    pub async fn set_remote_description(&self, description_json: String) -> Result<(), String> {
        let desc: RTCSessionDescription =
            serde_json::from_str(&description_json).map_err(|e| e.to_string())?;
        self.inner
            .set_remote_description(desc)
            .await
            .map_err(|e| e.to_string())
    }

    /// The current local description, if any has been set, JSON-encoded.
    pub async fn local_description(&self) -> Option<String> {
        let desc = self.inner.local_description().await?;
        serde_json::to_string(&desc).ok()
    }

    /// `candidate_json` is a JSON-encoded `RTCIceCandidateInit`, as received from the
    /// remote peer's [`PeerConnectionEvent::IceCandidate`] over your signaling channel.
    pub async fn add_ice_candidate(&self, candidate_json: String) -> Result<(), String> {
        let candidate: RTCIceCandidateInit =
            serde_json::from_str(&candidate_json).map_err(|e| e.to_string())?;
        self.inner
            .add_ice_candidate(candidate)
            .await
            .map_err(|e| e.to_string())
    }

    /// Creates a local data channel (triggers renegotiation via `NegotiationNeeded`
    /// unless this is the very first one, negotiated in the initial offer).
    pub async fn create_data_channel(&self, label: String) -> Result<RtcDataChannel, String> {
        let dc = self
            .inner
            .create_data_channel(&label, None)
            .await
            .map_err(|e| e.to_string())?;
        Ok(RtcDataChannel { inner: dc })
    }

    /// Fetches the handle for a data channel the remote peer created, previously
    /// announced via [`PeerConnectionEvent::DataChannel`].
    pub async fn take_remote_data_channel(&self, channel_id: String) -> Result<RtcDataChannel, String> {
        let dc = self
            .shared
            .remote_data_channels
            .lock()
            .await
            .get(&channel_id)
            .cloned()
            .ok_or_else(|| format!("no remote data channel with id '{channel_id}'"))?;
        Ok(RtcDataChannel { inner: dc })
    }

    /// Fetches the handle for a remote media track, previously announced via
    /// [`PeerConnectionEvent::RemoteTrack`].
    pub async fn take_remote_track(&self, track_id: String) -> Result<RtcRemoteTrack, String> {
        let track = self
            .shared
            .remote_tracks
            .lock()
            .await
            .get(&track_id)
            .cloned()
            .ok_or_else(|| format!("no remote track with id '{track_id}'"))?;
        Ok(RtcRemoteTrack { inner: track })
    }

    /// Adds a local media sender for `kind` (e.g. `MediaKind::Audio` for an
    /// Opus-encoded microphone track) and triggers renegotiation. `mime_type` should
    /// match one registered on the `MediaEngine` - see `MIME_TYPE_OPUS` etc. in
    /// `rtc::peer_connection::configuration::media_engine`; every default codec is
    /// already registered by [`create`], so passing e.g. `"audio/opus"` here works
    /// without any extra setup.
    pub async fn add_media_sender(
        &self,
        kind: MediaKind,
        mime_type: String,
    ) -> Result<RtcMediaSender, String> {
        let ssrc: u32 = rand::random();
        let stream_id = self.shared.fresh_id("stream");
        let track_id = self.shared.fresh_id("track-local");
        let track = media::build_local_track(kind, mime_type, ssrc, stream_id, track_id)?;
        let sender = self
            .inner
            .add_track(media::as_track_local(&track))
            .await
            .map_err(|e| e.to_string())?;
        Ok(RtcMediaSender::new(track, sender, ssrc))
    }

    pub async fn close(&self) -> Result<(), String> {
        self.inner.close().await.map_err(|e| e.to_string())
    }
}
