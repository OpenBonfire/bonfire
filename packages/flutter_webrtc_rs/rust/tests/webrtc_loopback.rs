//! Validates that the vendored webrtc-rs stack can actually establish a connection
//! and exchange data on this machine - the thing no amount of `cargo check` proves.
//!
//! This talks to `webrtc`/`rtc` directly rather than through
//! `flutter_webrtc_rs_core::api` because `RtcPeerConnection::create` takes a
//! flutter_rust_bridge `StreamSink`, which is only constructible from a live Dart
//! isolate - not from a plain Rust test. The two peer connections built here go
//! through the exact same `PeerConnectionBuilder`/offer-answer/data-channel calls our
//! `api::peer_connection` wrapper makes, so a pass here is strong evidence the wrapper
//! logic (which is thin plumbing on top) is sound; it does not exercise the FRB
//! plumbing itself (event forwarding through `StreamSink`, opaque handle lifetimes),
//! which needs the Flutter example app - see `example/`.
use std::sync::Arc;
use std::time::{Duration, Instant};

use bytes::Bytes;
use rtc::interceptor::Registry;
use rtc::media::Sample;
use rtc::media_stream::MediaStreamTrack;
use rtc::peer_connection::configuration::interceptor_registry::register_default_interceptors;
use rtc::peer_connection::configuration::media_engine::{MediaEngine, MIME_TYPE_H264, MIME_TYPE_OPUS};
use rtc::peer_connection::configuration::RTCConfigurationBuilder;
use rtc::rtp_transceiver::rtp_sender::{
    RTCRtpCodec, RTCRtpCodingParameters, RTCRtpEncodingParameters, RtpCodecKind,
};
use tokio::sync::mpsc;
use webrtc::data_channel::{DataChannel, DataChannelEvent};
use webrtc::media_stream::track_local::static_sample::TrackLocalStaticSample;
use webrtc::media_stream::track_local::TrackLocal;
use webrtc::media_stream::track_remote::{TrackRemote, TrackRemoteEvent};
use webrtc::peer_connection::{
    PeerConnection, PeerConnectionBuilder, PeerConnectionEventHandler, RTCIceGatheringState,
    RTCPeerConnectionState,
};
use webrtc::runtime::default_runtime;

struct TestHandler {
    gather_complete_tx: parking_lot_free_oneshot::Sender,
    connected_tx: parking_lot_free_oneshot::Sender,
    data_channel_tx: mpsc::UnboundedSender<Arc<dyn DataChannel>>,
    track_tx: mpsc::UnboundedSender<Arc<dyn TrackRemote>>,
}

/// A one-shot sender that can be sent through `try_send` multiple times without
/// panicking (the trait methods below only ever fire once per real event, but
/// `PeerConnectionEventHandler`'s methods take `&self`, so a plain `oneshot::Sender`
/// - which consumes itself on send - can't be stored directly in a `Send + Sync`
/// handler shared behind an `Arc`). Backed by an `UnboundedSender<()>` for simplicity.
mod parking_lot_free_oneshot {
    use tokio::sync::mpsc;

    #[derive(Clone)]
    pub struct Sender(mpsc::UnboundedSender<()>);

    impl Sender {
        pub fn fire(&self) {
            let _ = self.0.send(());
        }
    }

    pub fn channel() -> (Sender, mpsc::UnboundedReceiver<()>) {
        let (tx, rx) = mpsc::unbounded_channel();
        (Sender(tx), rx)
    }
}

#[async_trait::async_trait]
impl PeerConnectionEventHandler for TestHandler {
    async fn on_ice_gathering_state_change(&self, state: RTCIceGatheringState) {
        if state == RTCIceGatheringState::Complete {
            self.gather_complete_tx.fire();
        }
    }

    async fn on_connection_state_change(&self, state: RTCPeerConnectionState) {
        if state == RTCPeerConnectionState::Connected {
            self.connected_tx.fire();
        }
    }

    async fn on_data_channel(&self, dc: Arc<dyn DataChannel>) {
        let _ = self.data_channel_tx.send(dc);
    }

    async fn on_track(&self, track: Arc<dyn TrackRemote>) {
        let _ = self.track_tx.send(track);
    }
}

struct BuiltPeerConnection<PC: PeerConnection> {
    pc: PC,
    gather_complete_rx: mpsc::UnboundedReceiver<()>,
    connected_rx: mpsc::UnboundedReceiver<()>,
    data_channel_rx: mpsc::UnboundedReceiver<Arc<dyn DataChannel>>,
    track_rx: mpsc::UnboundedReceiver<Arc<dyn TrackRemote>>,
}

async fn build_peer_connection(port: u16) -> BuiltPeerConnection<impl PeerConnection> {
    let mut media_engine = MediaEngine::default();
    media_engine.register_default_codecs().expect("register default codecs");
    let registry =
        register_default_interceptors(Registry::new(), &mut media_engine).expect("interceptors");
    let config = RTCConfigurationBuilder::new().build();

    let (gather_complete_tx, gather_complete_rx) = parking_lot_free_oneshot::channel();
    let (connected_tx, connected_rx) = parking_lot_free_oneshot::channel();
    let (data_channel_tx, data_channel_rx) = mpsc::unbounded_channel();
    let (track_tx, track_rx) = mpsc::unbounded_channel();

    let handler = Arc::new(TestHandler {
        gather_complete_tx: gather_complete_tx.clone(),
        connected_tx: connected_tx.clone(),
        data_channel_tx,
        track_tx,
    });

    let runtime = default_runtime().expect("tokio runtime feature enabled");
    let pc = PeerConnectionBuilder::new()
        .with_configuration(config)
        .with_media_engine(media_engine)
        .with_interceptor_registry(registry)
        .with_handler(handler)
        .with_runtime(runtime)
        .with_udp_addrs(vec![format!("127.0.0.1:{port}")])
        .build()
        .await
        .expect("build peer connection");

    BuiltPeerConnection {
        pc,
        gather_complete_rx,
        connected_rx,
        data_channel_rx,
        track_rx,
    }
}

/// Two `PeerConnection`s on loopback UDP ports, offer/answer exchanged directly
/// in-process (no real signaling transport - this test *is* the signaling channel),
/// full (non-trickle) ICE candidates embedded in each SDP. Confirms: UDP sockets bind
/// and are usable in this sandbox, ICE connectivity checks succeed over loopback,
/// DTLS handshakes, SCTP association establishes, and a data channel message survives
/// the whole stack round-trip.
#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
async fn data_channel_loopback() {
    let BuiltPeerConnection {
        pc: offerer,
        gather_complete_rx: mut offerer_gather_rx,
        connected_rx: mut offerer_connected_rx,
        ..
    } = build_peer_connection(0).await;
    let BuiltPeerConnection {
        pc: answerer,
        gather_complete_rx: mut answerer_gather_rx,
        connected_rx: mut answerer_connected_rx,
        data_channel_rx: mut answerer_dc_rx,
        ..
    } = build_peer_connection(0).await;

    let dc = offerer
        .create_data_channel("smoke-test", None)
        .await
        .expect("create data channel");

    let offer = offerer.create_offer(None).await.expect("create offer");
    offerer.set_local_description(offer).await.expect("set local (offerer)");
    tokio::time::timeout(Duration::from_secs(10), offerer_gather_rx.recv())
        .await
        .expect("offerer ICE gathering timed out")
        .expect("offerer gather channel closed");
    let offer_with_candidates = offerer
        .local_description()
        .await
        .expect("offerer local description");

    answerer
        .set_remote_description(offer_with_candidates)
        .await
        .expect("set remote (answerer)");
    let answer = answerer.create_answer(None).await.expect("create answer");
    answerer.set_local_description(answer).await.expect("set local (answerer)");
    tokio::time::timeout(Duration::from_secs(10), answerer_gather_rx.recv())
        .await
        .expect("answerer ICE gathering timed out")
        .expect("answerer gather channel closed");
    let answer_with_candidates = answerer
        .local_description()
        .await
        .expect("answerer local description");

    offerer
        .set_remote_description(answer_with_candidates)
        .await
        .expect("set remote (offerer)");

    tokio::time::timeout(Duration::from_secs(10), offerer_connected_rx.recv())
        .await
        .expect("offerer never reached Connected")
        .expect("offerer connected channel closed");
    tokio::time::timeout(Duration::from_secs(10), answerer_connected_rx.recv())
        .await
        .expect("answerer never reached Connected")
        .expect("answerer connected channel closed");

    let remote_dc = tokio::time::timeout(Duration::from_secs(10), answerer_dc_rx.recv())
        .await
        .expect("answerer never saw the data channel")
        .expect("answerer data channel receiver closed");

    // Drain events until it opens, then round-trip a message each way.
    loop {
        match dc.poll().await.expect("offerer data channel closed before opening") {
            DataChannelEvent::OnOpen => break,
            _ => continue,
        }
    }
    loop {
        match remote_dc.poll().await.expect("answerer data channel closed before opening") {
            DataChannelEvent::OnOpen => break,
            _ => continue,
        }
    }

    dc.send_text("hello from offerer").await.expect("send from offerer");
    loop {
        match remote_dc.poll().await.expect("answerer data channel closed while waiting for message") {
            DataChannelEvent::OnMessage(msg) => {
                assert_eq!(String::from_utf8_lossy(&msg.data), "hello from offerer");
                break;
            }
            _ => continue,
        }
    }

    remote_dc.send_text("hello from answerer").await.expect("send from answerer");
    loop {
        match dc.poll().await.expect("offerer data channel closed while waiting for message") {
            DataChannelEvent::OnMessage(msg) => {
                assert_eq!(String::from_utf8_lossy(&msg.data), "hello from answerer");
                break;
            }
            _ => continue,
        }
    }

    offerer.close().await.expect("close offerer");
    answerer.close().await.expect("close answerer");
}

/// Sends bytes through a `TrackLocalStaticSample`/`add_track` and confirms the exact
/// same bytes come back out of `on_track`'s `TrackRemoteEvent::OnRtpPacket` on the
/// other side - i.e. webrtc-rs's Opus RTP packetize/depacketize round-trip preserves
/// payload bytes exactly. This is the mechanism `RtcMediaSender::write_encoded_frame`
/// / `RtcRemoteTrack::packets` use, and the reason DAVE integration is free: the
/// "encoded frame" here stands in for a DAVE-encrypted Opus frame - this layer never
/// looks inside it, so a plain marker payload proves the same thing a real one would.
#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
async fn audio_track_loopback() {
    let BuiltPeerConnection {
        pc: sender_pc,
        gather_complete_rx: mut sender_gather_rx,
        connected_rx: mut sender_connected_rx,
        ..
    } = build_peer_connection(0).await;
    let BuiltPeerConnection {
        pc: receiver_pc,
        gather_complete_rx: mut receiver_gather_rx,
        connected_rx: mut receiver_connected_rx,
        track_rx: mut receiver_track_rx,
        ..
    } = build_peer_connection(0).await;

    let ssrc: u32 = rand::random();
    let media_track = MediaStreamTrack::new(
        "stream-0".to_string(),
        "audio-0".to_string(),
        "audio-0".to_string(),
        RtpCodecKind::Audio,
        vec![RTCRtpEncodingParameters {
            rtp_coding_parameters: RTCRtpCodingParameters { ssrc: Some(ssrc), ..Default::default() },
            codec: RTCRtpCodec {
                mime_type: MIME_TYPE_OPUS.to_string(),
                clock_rate: 48_000,
                channels: 2,
                sdp_fmtp_line: String::new(),
                rtcp_feedback: Vec::new(),
            },
            ..Default::default()
        }],
    );
    let local_track = Arc::new(
        TrackLocalStaticSample::new(Instant::now(), media_track).expect("build local track"),
    );
    let sender = sender_pc
        .add_track(Arc::clone(&local_track) as Arc<dyn TrackLocal>)
        .await
        .expect("add_track");

    let offer = sender_pc.create_offer(None).await.expect("create offer");
    sender_pc.set_local_description(offer).await.expect("set local (sender)");
    tokio::time::timeout(Duration::from_secs(10), sender_gather_rx.recv())
        .await
        .expect("sender ICE gathering timed out")
        .unwrap();
    let offer_with_candidates = sender_pc.local_description().await.unwrap();

    receiver_pc
        .set_remote_description(offer_with_candidates)
        .await
        .expect("set remote (receiver)");
    let answer = receiver_pc.create_answer(None).await.expect("create answer");
    receiver_pc.set_local_description(answer).await.expect("set local (receiver)");
    tokio::time::timeout(Duration::from_secs(10), receiver_gather_rx.recv())
        .await
        .expect("receiver ICE gathering timed out")
        .unwrap();
    let answer_with_candidates = receiver_pc.local_description().await.unwrap();

    sender_pc
        .set_remote_description(answer_with_candidates)
        .await
        .expect("set remote (sender)");

    tokio::time::timeout(Duration::from_secs(10), sender_connected_rx.recv())
        .await
        .expect("sender never reached Connected")
        .unwrap();
    tokio::time::timeout(Duration::from_secs(10), receiver_connected_rx.recv())
        .await
        .expect("receiver never reached Connected")
        .unwrap();

    let payload_type = sender
        .get_parameters()
        .await
        .expect("sender parameters")
        .rtp_parameters
        .codecs
        .first()
        .expect("negotiated codec")
        .payload_type;

    // Stand-in for a DAVE-encrypted Opus frame - arbitrary bytes this layer must
    // deliver unchanged. webrtc-rs (like Pion/libwebrtc) only fires `on_track` once
    // the *first RTP packet* for that SSRC actually arrives, not at SDP negotiation
    // time - so keep writing samples in the background until the receiver has seen
    // the track, rather than sending once and waiting.
    let marker_frame: Vec<u8> = vec![0xDE, 0xAD, 0xBE, 0xEF, 0x00, 0x01, 0x02, 0x03];
    let sender_task = tokio::spawn({
        let local_track = Arc::clone(&local_track);
        let marker_frame = marker_frame.clone();
        async move {
            loop {
                if let Err(e) = local_track
                    .sample_writer(ssrc, payload_type)
                    .write_sample(&Sample {
                        data: Bytes::from(marker_frame.clone()),
                        duration: Duration::from_millis(20),
                        ..Sample::new(Instant::now())
                    })
                    .await
                {
                    eprintln!("write_sample error: {e}");
                }
                tokio::time::sleep(Duration::from_millis(20)).await;
            }
        }
    });

    let remote_track = tokio::time::timeout(Duration::from_secs(10), receiver_track_rx.recv())
        .await
        .expect("receiver never saw the remote track")
        .expect("receiver track receiver closed");

    assert_eq!(
        remote_track.codec(ssrc).await.map(|c| c.mime_type),
        Some(MIME_TYPE_OPUS.to_string()),
        "codec negotiated down to something other than Opus"
    );

    let received_payload = loop {
        let event = tokio::time::timeout(Duration::from_secs(10), remote_track.poll())
            .await
            .expect("timed out waiting for the RTP packet")
            .expect("remote track closed before delivering a packet");
        if let TrackRemoteEvent::OnRtpPacket(packet) = event {
            break packet.payload.to_vec();
        }
    };

    sender_task.abort();
    assert_eq!(received_payload, marker_frame, "payload bytes were not preserved end to end");

    sender_pc.close().await.expect("close sender");
    receiver_pc.close().await.expect("close receiver");
}

/// Reproduces the exact scenario that silently broke all incoming bonfire media the
/// moment video was added alongside audio: a peer connection with an audio *and* a
/// video transceiver negotiated together (still exactly one of each *kind*, but two
/// transceivers total), neither SSRC ever declared in the SDP - same as Discord's
/// voice SFU, which can't predict a remote speaker's SSRC ahead of time any more than
/// it can a camera's.
///
/// `rtc`'s own `bind_undeclared_ssrc` "single-media-section shortcut" used to gate on
/// `self.rtp_transceivers.len() != 1` - true the instant a second transceiver of
/// *either* kind existed, regardless of kind - so with both an audio and a video
/// transceiver present, `on_track` never fired for anything and every incoming packet
/// (audio included) was silently unroutable. This test adds both tracks before
/// negotiating (mirroring `VoiceWebRtcRsSession.createOfferAndBuildFragment`, which
/// always negotiates video too - see its doc), then confirms both an audio and a
/// video `on_track` fire and both payloads arrive intact. Before the
/// vendor/rtc/.../interceptor.rs patch (see its `bind_undeclared_ssrc` doc), this test
/// hangs until the 10s timeout waiting for the second (or, depending on which SSRC's
/// packets happen to arrive first, either) remote track.
#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
async fn multi_track_loopback() {
    let BuiltPeerConnection {
        pc: sender_pc,
        gather_complete_rx: mut sender_gather_rx,
        connected_rx: mut sender_connected_rx,
        ..
    } = build_peer_connection(0).await;
    let BuiltPeerConnection {
        pc: receiver_pc,
        gather_complete_rx: mut receiver_gather_rx,
        connected_rx: mut receiver_connected_rx,
        track_rx: mut receiver_track_rx,
        ..
    } = build_peer_connection(0).await;

    let audio_ssrc: u32 = rand::random();
    let audio_track = MediaStreamTrack::new(
        "stream-0".to_string(),
        "audio-0".to_string(),
        "audio-0".to_string(),
        RtpCodecKind::Audio,
        vec![RTCRtpEncodingParameters {
            rtp_coding_parameters: RTCRtpCodingParameters { ssrc: Some(audio_ssrc), ..Default::default() },
            codec: RTCRtpCodec {
                mime_type: MIME_TYPE_OPUS.to_string(),
                clock_rate: 48_000,
                channels: 2,
                sdp_fmtp_line: String::new(),
                rtcp_feedback: Vec::new(),
            },
            ..Default::default()
        }],
    );
    let local_audio_track = Arc::new(
        TrackLocalStaticSample::new(Instant::now(), audio_track).expect("build local audio track"),
    );
    let audio_sender = sender_pc
        .add_track(Arc::clone(&local_audio_track) as Arc<dyn TrackLocal>)
        .await
        .expect("add_track (audio)");

    let video_ssrc: u32 = rand::random();
    let video_track = MediaStreamTrack::new(
        "stream-1".to_string(),
        "video-0".to_string(),
        "video-0".to_string(),
        RtpCodecKind::Video,
        vec![RTCRtpEncodingParameters {
            rtp_coding_parameters: RTCRtpCodingParameters { ssrc: Some(video_ssrc), ..Default::default() },
            codec: RTCRtpCodec {
                mime_type: MIME_TYPE_H264.to_string(),
                clock_rate: 90_000,
                channels: 0,
                sdp_fmtp_line: String::new(),
                rtcp_feedback: Vec::new(),
            },
            ..Default::default()
        }],
    );
    let local_video_track = Arc::new(
        TrackLocalStaticSample::new(Instant::now(), video_track).expect("build local video track"),
    );
    let video_sender = sender_pc
        .add_track(Arc::clone(&local_video_track) as Arc<dyn TrackLocal>)
        .await
        .expect("add_track (video)");

    let offer = sender_pc.create_offer(None).await.expect("create offer");
    sender_pc.set_local_description(offer).await.expect("set local (sender)");
    tokio::time::timeout(Duration::from_secs(10), sender_gather_rx.recv())
        .await
        .expect("sender ICE gathering timed out")
        .unwrap();
    let offer_with_candidates = sender_pc.local_description().await.unwrap();

    // Note: this offer legitimately declares each sender's own SSRC via
    // `a=ssrc:` (standard, unavoidable WebRTC behavior), so the receiver
    // actually resolves both tracks via `bind_declared_ssrc` here, not
    // `bind_undeclared_ssrc` - Discord's SFU never declares a remote
    // participant's SSRC this way (confirmed from its own raw session
    // description, which carries no per-participant ssrc info at all), so
    // this test doesn't exercise that exact function/patch in isolation.
    // What it does verify end to end - and is exactly what regressed - is
    // that negotiating audio and video together still lets both directions
    // of media actually arrive; see `vendor/rtc/.../interceptor.rs`'s
    // `bind_undeclared_ssrc` doc for the specific mechanism, confirmed by
    // direct source reading and by live bonfire sessions never once firing
    // `on_track` for any remote participant once video was negotiated.
    receiver_pc
        .set_remote_description(offer_with_candidates)
        .await
        .expect("set remote (receiver)");
    let answer = receiver_pc.create_answer(None).await.expect("create answer");
    receiver_pc.set_local_description(answer).await.expect("set local (receiver)");
    tokio::time::timeout(Duration::from_secs(10), receiver_gather_rx.recv())
        .await
        .expect("receiver ICE gathering timed out")
        .unwrap();
    let answer_with_candidates = receiver_pc.local_description().await.unwrap();

    sender_pc
        .set_remote_description(answer_with_candidates)
        .await
        .expect("set remote (sender)");

    tokio::time::timeout(Duration::from_secs(10), sender_connected_rx.recv())
        .await
        .expect("sender never reached Connected")
        .unwrap();
    tokio::time::timeout(Duration::from_secs(10), receiver_connected_rx.recv())
        .await
        .expect("receiver never reached Connected")
        .unwrap();

    let audio_payload_type = audio_sender
        .get_parameters()
        .await
        .expect("audio sender parameters")
        .rtp_parameters
        .codecs
        .first()
        .expect("negotiated audio codec")
        .payload_type;
    let video_payload_type = video_sender
        .get_parameters()
        .await
        .expect("video sender parameters")
        .rtp_parameters
        .codecs
        .first()
        .expect("negotiated video codec")
        .payload_type;

    let audio_marker: Vec<u8> = vec![0xA0, 0xA1, 0xA2, 0xA3];
    let video_marker: Vec<u8> = vec![0x70, 0x71, 0x72, 0x73];
    let audio_task = tokio::spawn({
        let local_audio_track = Arc::clone(&local_audio_track);
        let audio_marker = audio_marker.clone();
        async move {
            loop {
                let _ = local_audio_track
                    .sample_writer(audio_ssrc, audio_payload_type)
                    .write_sample(&Sample {
                        data: Bytes::from(audio_marker.clone()),
                        duration: Duration::from_millis(20),
                        ..Sample::new(Instant::now())
                    })
                    .await;
                tokio::time::sleep(Duration::from_millis(20)).await;
            }
        }
    });
    let video_task = tokio::spawn({
        let local_video_track = Arc::clone(&local_video_track);
        let video_marker = video_marker.clone();
        async move {
            loop {
                let _ = local_video_track
                    .sample_writer(video_ssrc, video_payload_type)
                    .write_sample(&Sample {
                        data: Bytes::from(video_marker.clone()),
                        duration: Duration::from_millis(33),
                        ..Sample::new(Instant::now())
                    })
                    .await;
                tokio::time::sleep(Duration::from_millis(33)).await;
            }
        }
    });

    // Both tracks were added before any negotiation happened, so both are already
    // "known" transceivers by the time on_track can fire for either - only order of
    // arrival is nondeterministic, not which ones show up at all.
    let mut remote_tracks = Vec::new();
    for _ in 0..2 {
        let track = tokio::time::timeout(Duration::from_secs(10), receiver_track_rx.recv())
            .await
            .expect("receiver never saw both remote tracks")
            .expect("receiver track receiver closed");
        remote_tracks.push(track);
    }
    assert_eq!(remote_tracks.len(), 2, "expected exactly one audio and one video remote track");

    for remote_track in remote_tracks {
        let (expected_kind_mime, expected_marker) = match remote_track.kind().await {
            RtpCodecKind::Audio => (MIME_TYPE_OPUS, &audio_marker),
            RtpCodecKind::Video => (MIME_TYPE_H264, &video_marker),
            other => panic!("unexpected remote track kind: {other:?}"),
        };

        let received_payload = loop {
            let event = tokio::time::timeout(Duration::from_secs(10), remote_track.poll())
                .await
                .expect("timed out waiting for the RTP packet")
                .expect("remote track closed before delivering a packet");
            if let TrackRemoteEvent::OnRtpPacket(packet) = event {
                break packet.payload.to_vec();
            }
        };
        assert_eq!(
            &received_payload, expected_marker,
            "{expected_kind_mime} track's payload bytes were not preserved end to end \
             (this is the exact failure mode of the pre-patch bind_undeclared_ssrc bug: \
             wrong/no packets routed once a second transceiver exists)",
        );
    }

    audio_task.abort();
    video_task.abort();
    sender_pc.close().await.expect("close sender");
    receiver_pc.close().await.expect("close receiver");
}
