import 'dart:async';

import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/voice/services/voice_gateway.dart';
import 'package:bonfire/features/voice/services/voice_webrtc_session.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_connection.g.dart';

/// How far along the actual media (voice gateway + WebRTC) connection is,
/// layered on top of the plain "have we told Discord we want to be in this
/// channel" state.
enum VoiceMediaStatus {
  /// No media connection is being attempted (either not in a channel, or
  /// still waiting on session/server info from the main gateway).
  idle,

  /// Connecting to the per-guild voice gateway and waiting for it to
  /// identify and become ready.
  connectingGateway,

  /// Voice gateway is ready; negotiating SDP with the SFU over WebRTC.
  negotiating,

  /// The SFU's answer was applied. Note this does not yet mean audio is
  /// actually flowing to production Discord: DAVE (E2EE) isn't implemented,
  /// and Discord's voice servers currently close the connection with code
  /// 4017 once they notice DAVE was never negotiated.
  connected,

  /// Something failed - see [VoiceConnectionState.mediaError].
  failed,
}

/// The current voice connection: both which channel we've told Discord we
/// want to be in, and how the underlying voice-gateway/WebRTC connection is
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
  VoiceWebRtcSession? _webrtc;

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
      ),
    );
  }

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

  /// Kicks off the voice-gateway + WebRTC connection once we have
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
      debugPrint(
        '[Voice] _maybeStartMediaConnection: already connecting/connected for $sessionKey',
      );
      return;
    }
    debugPrint('[Voice] _maybeStartMediaConnection: starting for $sessionKey');
    // Set synchronously (before the await below yields control) so a
    // second handler firing right after this one - VOICE_STATE_UPDATE and
    // VOICE_SERVER_UPDATE typically arrive back to back - sees the guard
    // already in place instead of racing to open a second connection.
    _connectedSessionKey = sessionKey;
    _ssrc = null;

    await _closeGatewayAndWebrtc();

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
    );
    _gateway = gateway;

    final webrtc = VoiceWebRtcSession();
    _webrtc = webrtc;

    gateway.onClose.listen((close) {
      final message =
          close.description ??
          close.reason ??
          'Voice gateway closed unexpectedly (code ${close.code})';
      debugPrint('VoiceConnectionController: $message');
      _setMediaFailed(message);
    });

    gateway.onReady.listen((ready) async {
      debugPrint(
        '[Voice] gateway ready: ssrc=${ready.ssrc} modes=${ready.modes}',
      );
      _ssrc = ready.ssrc;
      try {
        state = _withMediaStatus(VoiceMediaStatus.negotiating);
        await webrtc.connect();
        debugPrint(
          '[Voice] webrtc session connected (mic captured), building offer',
        );
        final fragment = await webrtc.createOfferAndBuildFragment();
        debugPrint(
          '[Voice] sending select protocol, fragment length=${fragment.length}',
        );
        gateway.selectWebRtcProtocol(fragment);
      } catch (error, stackTrace) {
        debugPrint(
          'VoiceConnectionController: negotiation failed: $error\n$stackTrace',
        );
        _setMediaFailed(error.toString());
      }
    });

    gateway.onSessionDescription.listen((description) async {
      debugPrint(
        '[Voice] session description received: audioCodec=${description.audioCodec} '
        'sdpLength=${description.sdp?.length}',
      );
      final sdp = description.sdp;
      if (sdp == null) {
        _setMediaFailed('Session Description had no sdp (are we in UDP mode?)');
        return;
      }
      try {
        await webrtc.applyAnswer(sdp);
        state = _withMediaStatus(VoiceMediaStatus.connected);
        final ssrc = _ssrc;
        if (ssrc != null) {
          gateway.setSpeaking(ssrc: ssrc, speaking: true);
        }
      } catch (error, stackTrace) {
        debugPrint(
          'VoiceConnectionController: failed to apply SFU answer: $error\n$stackTrace',
        );
        _setMediaFailed(error.toString());
      }
    });

    try {
      debugPrint('[Voice] connecting to voice gateway wss://$endpoint');
      await gateway.connect();
      debugPrint('[Voice] voice gateway socket open');
    } catch (error, stackTrace) {
      debugPrint(
        'VoiceConnectionController: voice gateway connection failed: $error\n$stackTrace',
      );
      _setMediaFailed(error.toString());
    }
  }

  VoiceConnectionState _withMediaStatus(VoiceMediaStatus status) =>
      VoiceConnectionState(
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
  /// join/session is free to reconnect. Use [_closeGatewayAndWebrtc]
  /// instead when reconnecting for the *same* session key (see
  /// [_maybeStartMediaConnection]), so that guard isn't clobbered mid-check.
  Future<void> _teardownMedia() async {
    _connectedSessionKey = null;
    _ssrc = null;
    await _closeGatewayAndWebrtc();
  }

  Future<void> _closeGatewayAndWebrtc() async {
    final gateway = _gateway;
    final webrtc = _webrtc;
    _gateway = null;
    _webrtc = null;
    await gateway?.close();
    await webrtc?.dispose();
  }
}
