import 'dart:async';

import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/voice/services/dave_voice_session.dart';
import 'package:bonfire/features/voice/services/voice_gateway.dart';
import 'package:bonfire/features/voice/services/voice_media_session.dart';
import 'package:bonfire/features/voice/services/voice_transport_crypto.dart';
import 'package:bonfire/features/voice/services/voice_webrtc_rs_session.dart';
import 'package:collection/collection.dart';
import 'package:dave/dave.dart' as dave;
import 'package:firebridge/firebridge.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_connection.g.dart';

/// Selects the media transport: the raw-UDP path ([VoiceMediaSession],
/// Discord's own transport encryption over hand-rolled RTP), or the real
/// ICE/DTLS-SRTP path ([VoiceWebRtcRsSession], built on
/// `flutter_webrtc_rs`/webrtc-rs - **confirmed working for audio** against a
/// live Discord voice server; video is new and being tested). `true` here is
/// the actual current transport, not a test toggle - the UDP path is kept
/// only until it's removed outright.
const bool voiceUseWebRtcTransport = true;

/// How far along the actual media (voice gateway + UDP) connection is,
/// layered on top of the plain "have we told Discord we want to be in this
/// channel" state.
enum VoiceMediaStatus {
  /// No media connection is being attempted (either not in a channel, or
  /// still waiting on session/server info from the main gateway).
  idle,

  /// Connecting to the per-guild voice gateway and waiting for it to
  /// identify and become ready.
  connectingGateway,

  /// Voice gateway is ready; running IP discovery, selecting the UDP
  /// protocol, and (if the server supports it) the DAVE handshake.
  negotiating,

  /// Session Description was applied and the UDP media session has
  /// started capturing/sending and is ready to receive.
  connected,

  /// Something failed - see [VoiceConnectionState.mediaError].
  failed,
}

/// The current voice connection: both which channel we've told Discord we
/// want to be in, and how the underlying voice-gateway/UDP connection is
/// progressing.
class VoiceConnectionState {
  final Snowflake? guildId;
  final Snowflake? channelId;
  final String? sessionId;
  final String? voiceServerToken;
  final String? voiceServerEndpoint;
  final VoiceMediaStatus mediaStatus;
  final String? mediaError;

  const VoiceConnectionState({
    this.guildId,
    this.channelId,
    this.sessionId,
    this.voiceServerToken,
    this.voiceServerEndpoint,
    this.mediaStatus = VoiceMediaStatus.idle,
    this.mediaError,
  });

  bool get isConnected => channelId != null;
}

@Riverpod(keepAlive: true)
class VoiceConnectionController extends _$VoiceConnectionController {
  /// The voice gateway connection for the current channel, once we have
  /// enough info (session id + server token/endpoint) to open it. Null
  /// whenever [VoiceConnectionState.mediaStatus] is
  /// [VoiceMediaStatus.idle].
  VoiceGateway? _gateway;
  DaveVoiceSession? _daveSession;
  VoiceMediaSession? _mediaSession;
  VoiceWebRtcRsSession? _webrtcSession;

  /// Identifies the (guildId, sessionId, endpoint) combination media is
  /// currently connected/connecting for, so repeated `VOICE_SERVER_UPDATE`s
  /// carrying the same info don't restart the connection.
  String? _connectedSessionKey;

  int? _ssrc;

  @override
  VoiceConnectionState build() {
    final client = ref.watch(clientControllerProvider);
    if (client == null) return const VoiceConnectionState();

    final voiceStateSub = client.onVoiceStateUpdate.listen(
      _handleVoiceStateUpdate,
    );
    final voiceServerSub = client.onVoiceServerUpdate.listen(
      _handleVoiceServerUpdate,
    );
    ref.onDispose(voiceStateSub.cancel);
    ref.onDispose(voiceServerSub.cancel);
    ref.onDispose(() {
      unawaited(_teardownMedia());
    });

    return const VoiceConnectionState();
  }

  /// Tell Discord we want to join [channelId] in [guildId]. Sets [state]
  /// immediately rather than waiting on [_handleVoiceStateUpdate] to confirm
  /// it - that confirmation still arrives and reconciles [state] (it's how
  /// [sessionId] gets filled in), but the UI shouldn't be stuck showing
  /// "not connected" for however long that round-trip takes, and [leave]
  /// needs `state.guildId` to be set right away or it has nothing to send.
  void join(Snowflake guildId, Snowflake channelId) {
    final client = ref.read(clientControllerProvider);
    if (client == null) {
      debugPrint('[Voice] join() called with no client available; ignoring');
      return;
    }
    debugPrint('[Voice] join() guildId=$guildId channelId=$channelId');

    unawaited(_teardownMedia());
    state = VoiceConnectionState(guildId: guildId, channelId: channelId);

    client.gateway.updateVoiceState(
      guildId,
      GatewayVoiceStateBuilder(
        channelId: channelId,
        muted: false,
        deafened: false,
        selfVideo: false,
      ),
    );
  }

  /// Starts local camera capture and adds a video sender to the current
  /// call - only meaningful once [VoiceConnectionState.mediaStatus] is
  /// [VoiceMediaStatus.connected] and [voiceUseWebRtcTransport] is on.
  /// Capture and hardware H264 encode happen entirely in Rust (see
  /// `capture_kit`, via [VoiceWebRtcRsSession.startLocalVideo]) - no camera
  /// handle to pass in from the UI layer.
  ///
  /// Also announces `self_video: true` over the *main* gateway (see
  /// [GatewayVoiceStateBuilder.selfVideo]) - this, not the voice gateway's
  /// Video opcode (12) that [VoiceWebRtcRsSession.startLocalVideo] sends, is
  /// what drives the "live" camera indicator other clients render. Skipping
  /// this call is why the indicator never showed up at all, independent of
  /// whether the WebRTC video stream itself was flowing correctly.
  Future<void> startLocalVideo() async {
    final webrtcSession = _webrtcSession;
    if (webrtcSession == null) {
      debugPrint('[Voice] startLocalVideo() called with no active WebRTC session; ignoring');
      return;
    }
    await webrtcSession.startLocalVideo();
    _updateSelfVideo(true);
  }

  /// Stops local camera capture and announces it via opcode 12 - see
  /// [VoiceWebRtcRsSession.stopLocalVideo] - and clears `self_video` on the
  /// main gateway to match.
  Future<void> stopLocalVideo() async {
    await _webrtcSession?.stopLocalVideo();
    _updateSelfVideo(false);
  }

  /// Resends our current voice state with `self_video` set to [selfVideo],
  /// preserving whatever channel we're in. No-ops if we're not in a channel
  /// at all (nothing to update).
  void _updateSelfVideo(bool selfVideo) {
    final client = ref.read(clientControllerProvider);
    final guildId = state.guildId;
    final channelId = state.channelId;
    if (client == null || guildId == null || channelId == null) return;

    client.gateway.updateVoiceState(
      guildId,
      GatewayVoiceStateBuilder(
        channelId: channelId,
        muted: false,
        deafened: false,
        selfVideo: selfVideo,
      ),
    );
  }

  /// Decoded remote video frames for the current call, or `null` if there is
  /// no active WebRTC session to receive them on. See
  /// [VoiceWebRtcRsSession.onRemoteVideoFrame].
  Stream<RemoteVideoFrameEvent>? get remoteVideoFrames => _webrtcSession?.onRemoteVideoFrame;

  void leave() {
    final client = ref.read(clientControllerProvider);
    final guildId = state.guildId;

    if (client != null && guildId != null) {
      client.gateway.updateVoiceState(
        guildId,
        GatewayVoiceStateBuilder(
          channelId: null,
          muted: false,
          deafened: false,
          selfVideo: false,
        ),
      );
    }

    unawaited(_teardownMedia());

    // Clear unconditionally so leaving always works locally, even if the
    // guild id was somehow missing or the send above didn't go through.
    state = const VoiceConnectionState();
  }

  void _handleVoiceStateUpdate(VoiceStateUpdateEvent event) {
    final client = ref.read(clientControllerProvider);
    debugPrint(
      '[Voice] VOICE_STATE_UPDATE received: eventUserId=${event.userId} '
      'selfUserId=${client?.user.id} channelId=${event.channelId} '
      'sessionId=${event.sessionId}',
    );
    if (client == null || event.userId != client.user.id) {
      debugPrint('[Voice] VOICE_STATE_UPDATE ignored (not for our own user)');
      return;
    }

    if (event.channelId == null) {
      debugPrint(
        '[Voice] our voice state now has no channel; tearing down media',
      );
      unawaited(_teardownMedia());
      state = const VoiceConnectionState();
    } else {
      state = VoiceConnectionState(
        guildId: event.guildId,
        channelId: event.channelId,
        sessionId: event.sessionId,
        voiceServerToken: state.voiceServerToken,
        voiceServerEndpoint: state.voiceServerEndpoint,
      );
      unawaited(_maybeStartMediaConnection());
    }
  }

  void _handleVoiceServerUpdate(VoiceServerUpdateEvent event) {
    debugPrint(
      '[Voice] VOICE_SERVER_UPDATE received: eventGuildId=${event.guildId} '
      'stateGuildId=${state.guildId} endpoint=${event.endpoint}',
    );
    if (event.guildId != state.guildId) {
      debugPrint('[Voice] VOICE_SERVER_UPDATE ignored (guild id mismatch)');
      return;
    }

    // Set directly rather than through copyWith - endpoint can legitimately
    // become null (the voice server is being reallocated) and copyWith's
    // `??` would otherwise keep the stale value.
    state = VoiceConnectionState(
      guildId: state.guildId,
      channelId: state.channelId,
      sessionId: state.sessionId,
      voiceServerToken: event.token,
      voiceServerEndpoint: event.endpoint,
    );
    unawaited(_maybeStartMediaConnection());
  }

  /// Kicks off the voice-gateway + UDP media connection once we have
  /// everything Discord requires to identify on the voice gateway: which
  /// channel, our session id (from `VOICE_STATE_UPDATE`), and the voice
  /// server's token/endpoint (from `VOICE_SERVER_UPDATE`). These two events
  /// can arrive in either order, so both handlers call this and it no-ops
  /// until both have shown up.
  Future<void> _maybeStartMediaConnection() async {
    final client = ref.read(clientControllerProvider);
    final guildId = state.guildId;
    final channelId = state.channelId;
    final sessionId = state.sessionId;
    final token = state.voiceServerToken;
    final endpoint = state.voiceServerEndpoint;

    if (client == null ||
        guildId == null ||
        channelId == null ||
        sessionId == null ||
        token == null ||
        endpoint == null) {
      debugPrint(
        '[Voice] _maybeStartMediaConnection: still waiting on '
        '${client == null ? 'client ' : ''}'
        '${guildId == null ? 'guildId ' : ''}'
        '${channelId == null ? 'channelId ' : ''}'
        '${sessionId == null ? 'sessionId ' : ''}'
        '${token == null ? 'voiceServerToken ' : ''}'
        '${endpoint == null ? 'voiceServerEndpoint ' : ''}',
      );
      return;
    }

    final sessionKey = '$guildId:$sessionId:$endpoint';
    if (_connectedSessionKey == sessionKey) {
      debugPrint('[Voice] _maybeStartMediaConnection: already connecting/connected for $sessionKey');
      return;
    }
    // Set synchronously (before the await below yields control) so a
    // second handler firing right after this one - VOICE_STATE_UPDATE and
    // VOICE_SERVER_UPDATE typically arrive back to back - sees the guard
    // already in place instead of racing to open a second connection.
    _connectedSessionKey = sessionKey;
    _ssrc = null;

    await _closeGatewayAndMedia();

    state = VoiceConnectionState(
      guildId: guildId,
      channelId: channelId,
      sessionId: sessionId,
      voiceServerToken: token,
      voiceServerEndpoint: endpoint,
      mediaStatus: VoiceMediaStatus.connectingGateway,
    );

    final gateway = VoiceGateway(
      endpoint: endpoint,
      guildId: guildId,
      userId: client.user.id,
      sessionId: sessionId,
      token: token,
      maxDaveProtocolVersion: dave.daveMaxSupportedProtocolVersion(),
    );
    _gateway = gateway;

    // Created immediately (rather than lazily once DAVE is confirmed
    // active) and subscribes right away - the external sender package
    // (opcode 25) "may be sent immediately on Gateway connect", so we can't
    // risk missing early DAVE opcodes by wiring this up later.
    final daveSession = DaveVoiceSession(
      gateway: gateway,
      selfUserId: client.user.id,
      groupId: channelId,
    );
    _daveSession = daveSession;

    VoiceMediaSession? mediaSession;
    VoiceWebRtcRsSession? webrtcSession;
    if (voiceUseWebRtcTransport) {
      webrtcSession = VoiceWebRtcRsSession(
        gateway: gateway,
        selfUserId: client.user.id,
        daveSession: daveSession,
      );
      _webrtcSession = webrtcSession;
    } else {
      mediaSession = VoiceMediaSession(
        gateway: gateway,
        selfUserId: client.user.id,
        daveSession: daveSession,
      );
      _mediaSession = mediaSession;
    }

    gateway.onClose.listen((close) {
      final message = close.description ??
          close.reason ??
          'Voice gateway closed unexpectedly (code ${close.code})';
      debugPrint('VoiceConnectionController: $message');
      _setMediaFailed(message);
    });

    gateway.onSpeaking.listen((event) {
      final userId = Snowflake.parse(event.userId);
      mediaSession?.handleSpeaking(userId: userId, ssrc: event.ssrc);
      webrtcSession?.handleSpeaking(userId: userId, ssrc: event.ssrc);
    });

    // Never actually subscribed to before now - meaning every Video (opcode
    // 12) event Discord ever sent back, including any echo of our own
    // state or another participant's, was silently dropped with no way to
    // tell from the logs. Logging-only for now (not wired into rendering -
    // remote video frames are already identified by SSRC via handleSpeaking-
    // style routing in VoiceWebRtcRsSession), specifically to answer: does
    // Discord ever send anything on this channel at all.
    gateway.onVideo.listen((update) {
      debugPrint(
        '[Voice] <- video (12): userId=${update.userId} audioSsrc=${update.audioSsrc} '
        'videoSsrc=${update.videoSsrc} rtxSsrc=${update.rtxSsrc} '
        'streams=${update.streams.map((s) => '${s.type}/${s.rid}/ssrc=${s.ssrc}/active=${s.active}').join(',')}',
      );
    });

    gateway.onReady.listen((ready) async {
      debugPrint(
        '[Voice] gateway ready: ssrc=${ready.ssrc} modes=${ready.modes} '
        'streams=${ready.streams.length}',
      );
      _ssrc = ready.ssrc;
      try {
        state = _withMediaStatus(VoiceMediaStatus.negotiating);

        final webrtc = webrtcSession;
        if (webrtc != null) {
          webrtc.localSsrc = ready.ssrc;
          // Video, if offered at all, is negotiated once here as part of
          // the initial offer/answer - never via a later renegotiation.
          // Re-sending Select Protocol mid-call to add video is confirmed
          // to crash the voice server outright (gateway close code 4013,
          // "WebRTC crashed"), taking the whole call down, audio included.
          // Discord's own real mechanism for a mid-call camera toggle is
          // opcode 12 "Video" (see VoiceGateway.sendVideo) against an SSRC
          // negotiated up front - see VoiceWebRtcRsSession's class doc.
          final videoStream = ready.streams.where((s) => s.type == 'video').firstOrNull;
          final fragment = await webrtc.createOfferAndBuildFragment(videoStream: videoStream);
          gateway.selectWebRtcProtocol(
            fragment,
            opusPayloadType: webrtc.opusPayloadType ?? 111,
            videoPayloadType: webrtc.videoPayloadType,
            videoRtxPayloadType: webrtc.videoRtxPayloadType,
          );
          return;
        }

        final mode = pickTransportEncryptionMode(ready.modes);
        if (mode == null) {
          _setMediaFailed('Voice server offered no transport encryption mode we support');
          return;
        }

        final discovered = await mediaSession!.connectAndDiscoverIp(ready);
        debugPrint('[Voice] IP discovery: ${discovered.address}:${discovered.port}');
        gateway.selectUdpProtocol(address: discovered.address, port: discovered.port, mode: mode);
      } catch (error, stackTrace) {
        debugPrint('VoiceConnectionController: negotiation failed: $error\n$stackTrace');
        _setMediaFailed(error.toString());
      }
    });

    gateway.onSessionDescription.listen((description) async {
      debugPrint(
        '[Voice] session description received: audioCodec=${description.audioCodec} '
        'mode=${description.mode} daveVersion=${description.daveProtocolVersion} '
        'sdp=${description.sdp != null}',
      );
      try {
        if (webrtcSession != null) {
          final sdp = description.sdp;
          if (sdp == null) {
            _setMediaFailed('Session Description had no sdp (are we in UDP mode?)');
            return;
          }
          await webrtcSession.applyAnswer(sdp);
        } else {
          final mode = description.mode;
          final secretKey = description.secretKey;
          if (mode == null || secretKey == null) {
            _setMediaFailed('Session Description had no transport mode/secret key (are we in WebRTC mode?)');
            return;
          }
          await mediaSession!.start(mode: mode, secretKey: secretKey);
        }
        state = _withMediaStatus(VoiceMediaStatus.connected);
        final ssrc = _ssrc;
        if (ssrc != null) {
          gateway.setSpeaking(ssrc: ssrc, speaking: true);
        }
      } catch (error, stackTrace) {
        debugPrint('VoiceConnectionController: failed to start media session: $error\n$stackTrace');
        _setMediaFailed(error.toString());
      }
    });

    try {
      debugPrint('[Voice] connecting to voice gateway wss://$endpoint');
      await gateway.connect();
      debugPrint('[Voice] voice gateway socket open');
    } catch (error, stackTrace) {
      debugPrint('VoiceConnectionController: voice gateway connection failed: $error\n$stackTrace');
      _setMediaFailed(error.toString());
    }
  }

  VoiceConnectionState _withMediaStatus(VoiceMediaStatus status) => VoiceConnectionState(
        guildId: state.guildId,
        channelId: state.channelId,
        sessionId: state.sessionId,
        voiceServerToken: state.voiceServerToken,
        voiceServerEndpoint: state.voiceServerEndpoint,
        mediaStatus: status,
      );

  void _setMediaFailed(String error) {
    state = VoiceConnectionState(
      guildId: state.guildId,
      channelId: state.channelId,
      sessionId: state.sessionId,
      voiceServerToken: state.voiceServerToken,
      voiceServerEndpoint: state.voiceServerEndpoint,
      mediaStatus: VoiceMediaStatus.failed,
      mediaError: error,
    );
  }

  /// Full teardown: also clears [_connectedSessionKey], so a subsequent
  /// join/session is free to reconnect. Use [_closeGatewayAndMedia]
  /// instead when reconnecting for the *same* session key (see
  /// [_maybeStartMediaConnection]), so that guard isn't clobbered mid-check.
  Future<void> _teardownMedia() async {
    _connectedSessionKey = null;
    _ssrc = null;
    await _closeGatewayAndMedia();
  }

  Future<void> _closeGatewayAndMedia() async {
    final gateway = _gateway;
    final daveSession = _daveSession;
    final mediaSession = _mediaSession;
    final webrtcSession = _webrtcSession;
    _gateway = null;
    _daveSession = null;
    _mediaSession = null;
    _webrtcSession = null;
    // Order matters: stop using ratchets before freeing them, and free the
    // MLS session before tearing down the socket/peer connection they were
    // negotiated over.
    await mediaSession?.dispose();
    await webrtcSession?.dispose();
    await daveSession?.dispose();
    await gateway?.close();
  }
}
