import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebridge/firebridge.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Opcodes used on Discord's voice Gateway.
///
/// Reference: https://docs.discord.food/topics/voice-connections
enum VoiceOpcode {
  identify(0),
  selectProtocol(1),
  ready(2),
  heartbeat(3),
  sessionDescription(4),
  speaking(5),
  heartbeatAck(6),
  resume(7),
  hello(8),
  resumed(9),
  clientsConnect(11),
  clientDisconnect(13);

  final int value;
  const VoiceOpcode(this.value);

  static VoiceOpcode? fromValue(int value) {
    for (final opcode in values) {
      if (opcode.value == value) return opcode;
    }
    return null;
  }
}

/// The payload of a [VoiceOpcode.ready] event.
class VoiceReady {
  final int ssrc;
  final String ip;
  final int port;
  final List<String> modes;

  const VoiceReady({
    required this.ssrc,
    required this.ip,
    required this.port,
    required this.modes,
  });

  factory VoiceReady.fromJson(Map<String, dynamic> json) => VoiceReady(
        ssrc: json['ssrc'] as int,
        ip: json['ip'] as String? ?? '',
        port: json['port'] as int? ?? 0,
        modes: (json['modes'] as List?)?.cast<String>() ?? const [],
      );
}

/// The payload of a [VoiceOpcode.sessionDescription] event.
///
/// In WebRTC mode (the only mode this client speaks so far) this carries the
/// SFU's SDP answer. `mode`/`secret_key` only apply to UDP-mode connections
/// and are intentionally not parsed here.
class VoiceSessionDescription {
  final String? audioCodec;
  final String? videoCodec;
  final String? mediaSessionId;
  final String? sdp;

  const VoiceSessionDescription({
    this.audioCodec,
    this.videoCodec,
    this.mediaSessionId,
    this.sdp,
  });

  factory VoiceSessionDescription.fromJson(Map<String, dynamic> json) =>
      VoiceSessionDescription(
        audioCodec: json['audio_codec'] as String?,
        videoCodec: json['video_codec'] as String?,
        mediaSessionId: json['media_session_id'] as String?,
        sdp: json['sdp'] as String?,
      );
}

/// Known voice gateway close codes.
///
/// 4017 is what real Discord voice servers currently send when a client
/// completes signalling but never negotiates DAVE (E2EE) - which is every
/// connection this client makes today, since DAVE isn't implemented yet.
const voiceCloseCodeDescriptions = <int, String>{
  4001: 'Unknown opcode',
  4002: 'Failed to decode payload',
  4003: 'Not authenticated',
  4004: 'Authentication failed',
  4005: 'Already authenticated',
  4006: 'Session no longer valid',
  4009: 'Session timeout',
  4011: 'Server not found',
  4012: 'Unknown protocol',
  4014: 'Disconnected (kicked, channel deleted, or moved)',
  4015: 'Voice server crashed',
  4016: 'Unknown encryption mode',
  4017: 'Disconnected: DAVE end-to-end encryption is required by this '
      'server and was not negotiated (not implemented by this client yet)',
};

/// A close event from the voice gateway.
class VoiceGatewayClose {
  final int? code;
  final String? reason;

  const VoiceGatewayClose({this.code, this.reason});

  /// A human-readable explanation of [code], for the codes Discord
  /// documents. Null for codes without a documented meaning.
  String? get description => voiceCloseCodeDescriptions[code];
}

/// A connection to Discord's per-guild voice Gateway.
///
/// This only speaks the WebRTC transport mode: it exchanges SDP with the
/// voice SFU over this websocket, but does no UDP socket work and no manual
/// RTP encryption itself - all of that is handled by libwebrtc via
/// flutter_webrtc's `RTCPeerConnection` once a
/// [VoiceSessionDescription.sdp] answer is applied (see
/// [VoiceWebRtcSession] in `voice_webrtc_session.dart`).
///
/// Does NOT implement DAVE (Discord's MLS-based E2EE layer) - see the
/// voice feature's other notes. Real Discord voice servers reject
/// non-DAVE clients once negotiation reaches this point (close code 4017),
/// so this class alone cannot yet complete a connection to production
/// Discord. It's still useful groundwork: DAVE sits on top of this exact
/// signalling flow, encrypting the media frames this negotiates rather
/// than replacing any of it.
class VoiceGateway {
  VoiceGateway({
    required this.endpoint,
    required this.guildId,
    required this.userId,
    required this.sessionId,
    required this.token,
  });

  /// The voice server host, as given by `VOICE_SERVER_UPDATE` (no scheme or
  /// path - just `host[:port]`).
  final String endpoint;
  final Snowflake guildId;
  final Snowflake userId;
  final String sessionId;
  final String token;

  /// Voice gateway version. v8 is the minimum with resuming support; see
  /// https://docs.discord.food/topics/voice-connections.
  static const _gatewayVersion = 8;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _heartbeatTimer;
  bool _lastHeartbeatAcked = true;
  bool _closing = false;

  final _readyController = StreamController<VoiceReady>.broadcast();
  final _sessionDescriptionController =
      StreamController<VoiceSessionDescription>.broadcast();
  final _closeController = StreamController<VoiceGatewayClose>.broadcast();

  Stream<VoiceReady> get onReady => _readyController.stream;
  Stream<VoiceSessionDescription> get onSessionDescription =>
      _sessionDescriptionController.stream;

  /// Fires when the underlying websocket closes unexpectedly (i.e. not as a
  /// result of calling [close] on this side - see the ordering note there).
  Stream<VoiceGatewayClose> get onClose => _closeController.stream;

  Future<void> connect() async {
    final uri = Uri.parse('wss://$endpoint').replace(
      queryParameters: {'v': '$_gatewayVersion'},
    );
    debugPrint('VoiceGateway: opening $uri');

    final channel = WebSocketChannel.connect(uri);
    await channel.ready;
    debugPrint('VoiceGateway: socket ready');
    _channel = channel;

    _subscription = channel.stream.listen(
      _handleMessage,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('VoiceGateway error: $error\n$stackTrace');
      },
      onDone: () {
        debugPrint(
          'VoiceGateway: socket closed, code=${channel.closeCode} reason=${channel.closeReason}',
        );
        _heartbeatTimer?.cancel();
        if (!_closeController.isClosed) {
          _closeController.add(VoiceGatewayClose(
            code: channel.closeCode,
            reason: channel.closeReason,
          ));
        }
      },
      cancelOnError: false,
    );
  }

  void _send(VoiceOpcode opcode, Object? data) {
    debugPrint('VoiceGateway: -> ${opcode.name} (${opcode.value})');
    _channel?.sink.add(jsonEncode({'op': opcode.value, 'd': data}));
  }

  void _handleMessage(dynamic raw) {
    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (error) {
      debugPrint('VoiceGateway: failed to decode payload: $error\nraw: $raw');
      return;
    }

    final opcode = VoiceOpcode.fromValue(payload['op'] as int);
    final data = payload['d'];
    debugPrint('VoiceGateway: <- ${opcode?.name ?? payload['op']}: $data');

    try {
      switch (opcode) {
        case VoiceOpcode.hello:
          final interval = ((data as Map)['heartbeat_interval'] as num).toInt();
          _startHeartbeating(Duration(milliseconds: interval));
          _identify();
        case VoiceOpcode.ready:
          _readyController.add(VoiceReady.fromJson(data as Map<String, dynamic>));
        case VoiceOpcode.sessionDescription:
          _sessionDescriptionController
              .add(VoiceSessionDescription.fromJson(data as Map<String, dynamic>));
        case VoiceOpcode.heartbeatAck:
          _lastHeartbeatAcked = true;
        case VoiceOpcode.resumed:
          debugPrint('VoiceGateway: resumed session');
        case VoiceOpcode.clientsConnect:
        case VoiceOpcode.clientDisconnect:
          // Not needed for basic join/leave; ignored for now.
          break;
        default:
          debugPrint('VoiceGateway: unhandled opcode ${payload['op']}: $data');
      }
    } catch (error, stackTrace) {
      // A bad cast/shape here shouldn't take down the whole socket listener
      // silently - log it so a wire-format mismatch is visible instead of
      // just... nothing happening.
      debugPrint('VoiceGateway: error handling opcode ${payload['op']}: $error\n$stackTrace');
    }
  }

  void _identify() {
    _send(VoiceOpcode.identify, {
      'server_id': guildId.toString(),
      'user_id': userId.toString(),
      'session_id': sessionId,
      'token': token,
    });
  }

  void _startHeartbeating(Duration interval) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(interval, (_) {
      if (!_lastHeartbeatAcked) {
        debugPrint('VoiceGateway: heartbeat was not acked; connection may be dead');
      }
      _lastHeartbeatAcked = false;
      _send(VoiceOpcode.heartbeat, {'t': DateTime.now().millisecondsSinceEpoch});
    });
  }

  /// Sends Select Protocol (opcode 1) for the WebRTC transport, with
  /// [sdpFragment] built from the local offer (see
  /// `VoiceWebRtcSession.createOfferAndBuildFragment`).
  ///
  /// NOTE: the exact wire shape of `data` for WebRTC-mode Select Protocol
  /// isn't fully nailed down from public documentation - this follows the
  /// most consistent reading available (mirroring UDP mode's `data` object,
  /// with an `sdp` key holding the fragment). This needs verification
  /// against a live connection; if the SFU never responds with a Session
  /// Description, this shape is the first thing to double check.
  void selectWebRtcProtocol(String sdpFragment) {
    _send(VoiceOpcode.selectProtocol, {
      'protocol': 'webrtc',
      'data': {'sdp': sdpFragment},
      'rtc_connection_id': _generateUuidV4(),
      'codecs': [
        {
          'name': 'opus',
          'type': 'audio',
          'priority': 1000,
          'payload_type': 111,
        },
      ],
    });
  }

  /// Sends a Speaking (opcode 5) update. [ssrc] should be the value from
  /// [VoiceReady.ssrc].
  void setSpeaking({required int ssrc, required bool speaking}) {
    _send(VoiceOpcode.speaking, {
      'speaking': speaking ? 1 : 0,
      'delay': 0,
      'ssrc': ssrc,
    });
  }

  /// Closes the connection. Cancels the socket subscription before closing
  /// the sink so a self-initiated close never spuriously fires [onClose] -
  /// that stream is reserved for closes we didn't ask for.
  Future<void> close() async {
    if (_closing) return;
    _closing = true;
    _heartbeatTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    await _readyController.close();
    await _sessionDescriptionController.close();
    await _closeController.close();
  }
}

final _uuidRandom = Random.secure();

/// A random (v4) UUID, used for `rtc_connection_id`. Not security-sensitive
/// (it's just an analytics/tracking identifier per the docs), so a plain
/// [Random.secure] fill is enough without pulling in the `uuid` package.
String _generateUuidV4() {
  final bytes = List<int>.generate(16, (_) => _uuidRandom.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10

  String hex(int start, int end) => bytes
      .sublist(start, end)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
