import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebridge/firebridge.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Opcodes used on Discord's voice Gateway, including the DAVE (E2EE)
/// protocol opcodes (21-31).
///
/// Reference: https://docs.discord.food/topics/voice-connections and the
/// DAVE protocol whitepaper (https://daveprotocol.com/), whose "opcodes"
/// section has the exact wire format for 21-31 - several of which are
/// raw binary frames, not JSON (see [VoiceGateway]'s framing handling).
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
  video(12),
  clientDisconnect(13),
  davePrepareTransition(21),
  daveExecuteTransition(22),
  daveTransitionReady(23),
  davePrepareEpoch(24),
  daveMlsExternalSenderPackage(25),
  daveMlsKeyPackage(26),
  daveMlsProposals(27),
  daveMlsCommitWelcome(28),
  daveMlsAnnounceCommitTransition(29),
  daveMlsWelcome(30),
  daveMlsInvalidCommitWelcome(31);

  final int value;
  const VoiceOpcode(this.value);

  static VoiceOpcode? fromValue(int value) {
    for (final opcode in values) {
      if (opcode.value == value) return opcode;
    }
    return null;
  }
}

/// One entry of [VoiceReady.streams] - a send stream (video, screen share, or
/// a simulcast test layer) the server pre-allocated SSRCs for, in response
/// to the `streams` the client proposed in Identify (see
/// `VoiceGateway._identify`'s `video`/`streams` fields). Populated *before*
/// the client ever sends any video - per
/// https://docs.discord.food/topics/voice-connections: "When `streams` is
/// populated, the voice server has assigned local send SSRCs for the
/// offered simulcast streams." Video is meant to be negotiated once, here
/// and in the initial SDP offer, then merely turned on/off later via
/// [VoiceOpcode.video] (opcode 12) - *not* via a second SDP exchange, which
/// is confirmed to crash the voice server (close code 4013).
class VoiceReadyStream {
  final String type;
  final int ssrc;
  final int? rtxSsrc;
  final String rid;
  final int quality;
  final bool active;

  const VoiceReadyStream({
    required this.type,
    required this.ssrc,
    this.rtxSsrc,
    required this.rid,
    required this.quality,
    required this.active,
  });

  factory VoiceReadyStream.fromJson(Map<String, dynamic> json) => VoiceReadyStream(
        type: json['type'] as String? ?? 'video',
        ssrc: json['ssrc'] as int,
        rtxSsrc: json['rtx_ssrc'] as int?,
        rid: json['rid'] as String? ?? '',
        quality: json['quality'] as int? ?? 0,
        active: json['active'] as bool? ?? false,
      );
}

/// The payload of a [VoiceOpcode.ready] event.
class VoiceReady {
  final int ssrc;
  final String ip;
  final int port;
  final List<String> modes;

  /// Server-assigned send streams for the video capability requested in
  /// Identify - see [VoiceReadyStream]'s doc. Empty if video wasn't
  /// requested (or the server didn't grant it).
  final List<VoiceReadyStream> streams;

  const VoiceReady({
    required this.ssrc,
    required this.ip,
    required this.port,
    required this.modes,
    this.streams = const [],
  });

  factory VoiceReady.fromJson(Map<String, dynamic> json) => VoiceReady(
        ssrc: json['ssrc'] as int,
        ip: json['ip'] as String? ?? '',
        port: json['port'] as int? ?? 0,
        modes: (json['modes'] as List?)?.cast<String>() ?? const [],
        streams: (json['streams'] as List?)
                ?.cast<Map<String, dynamic>>()
                .map(VoiceReadyStream.fromJson)
                .toList() ??
            const [],
      );
}

/// The payload of a [VoiceOpcode.sessionDescription] event.
class VoiceSessionDescription {
  final String? audioCodec;
  final String? videoCodec;
  final String? mediaSessionId;

  /// The transport encryption mode in use - see `VoiceTransportCrypto`.
  final String? mode;

  /// The 32-byte transport encryption key - see `VoiceTransportCrypto`.
  final Uint8List? secretKey;

  /// The DAVE protocol version in use for this call, or 0/null if DAVE
  /// isn't active.
  final int? daveProtocolVersion;

  /// The SFU's SDP answer, present only when [selectWebRtcProtocol] (rather
  /// than [selectUdpProtocol]) was used - see `VoiceWebRtcRsSession`.
  final String? sdp;

  const VoiceSessionDescription({
    this.audioCodec,
    this.videoCodec,
    this.mediaSessionId,
    this.mode,
    this.secretKey,
    this.daveProtocolVersion,
    this.sdp,
  });

  factory VoiceSessionDescription.fromJson(Map<String, dynamic> json) {
    final secretKeyList = json['secret_key'] as List?;
    return VoiceSessionDescription(
      audioCodec: json['audio_codec'] as String?,
      videoCodec: json['video_codec'] as String?,
      mediaSessionId: json['media_session_id'] as String?,
      mode: json['mode'] as String?,
      secretKey: secretKeyList == null ? null : Uint8List.fromList(secretKeyList.cast<int>()),
      daveProtocolVersion: json['dave_protocol_version'] as int?,
      sdp: json['sdp'] as String?,
    );
  }
}

/// `dave_protocol_prepare_transition` (opcode 21, JSON, server->client).
/// Announces an upcoming transition - most commonly a downgrade to no DAVE
/// (`transitionId == 0` means it can execute immediately).
class DavePrepareTransition {
  const DavePrepareTransition({required this.protocolVersion, required this.transitionId});
  final int protocolVersion;
  final int transitionId;
}

/// `dave_protocol_execute_transition` (opcode 22, JSON, server->client).
/// Confirms execution of a previously-announced transition.
class DaveExecuteTransition {
  const DaveExecuteTransition({required this.transitionId});
  final int transitionId;
}

/// `dave_protocol_prepare_epoch` (opcode 24, JSON, server->client).
/// Announces a new MLS epoch; `epoch == 1` means a brand new group is being
/// created and a key package must be generated and sent (opcode 26).
class DavePrepareEpoch {
  const DavePrepareEpoch({required this.protocolVersion, required this.epoch});
  final int protocolVersion;
  final int epoch;
}

/// `dave_mls_external_sender_package` (opcode 25, binary, server->client).
/// [data] is the raw `ExternalSender` bytes - pass directly to
/// `DaveSession.setExternalSender`.
class DaveExternalSenderPackage {
  const DaveExternalSenderPackage(this.data);
  final Uint8List data;
}

/// `dave_mls_proposals` (opcode 27, binary, server->client). [data] is the
/// operation-type byte plus the proposal/proposal-ref message bytes exactly
/// as received - pass directly to `DaveSession.processProposals`.
class DaveProposals {
  const DaveProposals(this.data);
  final Uint8List data;
}

/// `dave_mls_announce_commit_transition` (opcode 29, binary,
/// server->client). The "winning" commit for this epoch; existing group
/// members apply it via `DaveSession.processCommit`.
class DaveAnnounceCommitTransition {
  const DaveAnnounceCommitTransition({required this.transitionId, required this.commitData});
  final int transitionId;
  final Uint8List commitData;
}

/// `dave_mls_welcome` (opcode 30, binary, server->client). Adds a pending
/// member to the group; process via `DaveSession.processWelcome`.
class DaveWelcome {
  const DaveWelcome({required this.transitionId, required this.welcomeData});
  final int transitionId;
  final Uint8List welcomeData;
}

/// Opcode 11 (Clients Connect, JSON, server->client). Announces user IDs
/// newly present in the channel - DAVE needs these as "recognized user IDs"
/// when processing proposals/commits/welcomes.
class VoiceClientsConnect {
  const VoiceClientsConnect(this.userIds);
  final List<String> userIds;
}

/// Opcode 13 (Client Disconnect, JSON, server->client).
class VoiceClientDisconnect {
  const VoiceClientDisconnect(this.userId);
  final String userId;
}

/// Opcode 5 (Speaking, JSON, server->client), announcing which user a given
/// SSRC belongs to (and their speaking state). `VoiceMediaSession` uses
/// this to route incoming RTP packets to the right participant.
class VoiceSpeakingUpdate {
  const VoiceSpeakingUpdate({required this.userId, required this.ssrc, required this.speaking});
  final String userId;
  final int ssrc;
  final int speaking;
}

/// One stream's active/inactive state within a [VoiceOpcode.video] (opcode
/// 12) payload - mirrors [VoiceReadyStream]'s shape but only carries what
/// changes here (`active`), not the SSRC assignment (that's fixed at Ready
/// time and never changes).
class VoiceVideoStream {
  const VoiceVideoStream({required this.type, required this.rid, required this.ssrc, required this.active});
  final String type;
  final String rid;
  final int ssrc;
  final bool active;

  factory VoiceVideoStream.fromJson(Map<String, dynamic> json) => VoiceVideoStream(
        type: json['type'] as String? ?? 'video',
        rid: json['rid'] as String? ?? '',
        ssrc: json['ssrc'] as int,
        active: json['active'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {'type': type, 'rid': rid, 'ssrc': ssrc, 'active': active};
}

/// Opcode 12 (Video, JSON, bidirectional) - announces which of a
/// connection's pre-negotiated send streams (see [VoiceReadyStream]) are
/// currently active. This is how camera on/off gets communicated mid-call,
/// **not** a second SDP/Select Protocol exchange (confirmed: attempting the
/// latter crashes the voice server with close code 4013). Sent by this
/// client via [VoiceGateway.sendVideo]; received (with [userId] populated)
/// for remote participants' video state via [VoiceGateway.onVideo].
class VoiceVideoUpdate {
  const VoiceVideoUpdate({
    required this.userId,
    required this.audioSsrc,
    required this.videoSsrc,
    this.rtxSsrc,
    required this.streams,
  });

  /// Null for the echo of this client's own [VoiceGateway.sendVideo] call
  /// (if the server echoes it at all - unconfirmed), present for a remote
  /// participant's video state change.
  final String? userId;
  final int audioSsrc;
  final int videoSsrc;
  final int? rtxSsrc;
  final List<VoiceVideoStream> streams;

  factory VoiceVideoUpdate.fromJson(Map<String, dynamic> json) => VoiceVideoUpdate(
        userId: json['user_id'] as String?,
        audioSsrc: json['audio_ssrc'] as int,
        videoSsrc: json['video_ssrc'] as int,
        rtxSsrc: json['rtx_ssrc'] as int?,
        streams: (json['streams'] as List?)
                ?.cast<Map<String, dynamic>>()
                .map(VoiceVideoStream.fromJson)
                .toList() ??
            const [],
      );
}

/// Known voice gateway close codes.
///
/// 4017 is what real Discord voice servers currently send when a client
/// completes signalling but never negotiates DAVE (E2EE).
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
      'server and was not negotiated in time',
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

/// A connection to Discord's per-guild voice Gateway, over UDP transport.
///
/// Handles the base voice protocol (identify/heartbeat/select-protocol/
/// session-description/speaking) as well as the DAVE protocol opcodes
/// (21-31) needed for end-to-end encryption. Several DAVE opcodes are raw
/// binary WebSocket frames rather than JSON text - see
/// https://docs.discord.food/topics/voice-connections#binary-websocket-messages.
/// This class only handles the signalling; actual UDP media transport (RTP,
/// transport encryption, DAVE frame encryption, Opus) lives in
/// `VoiceMediaSession`.
class VoiceGateway {
  VoiceGateway({
    required this.endpoint,
    required this.guildId,
    required this.userId,
    required this.sessionId,
    required this.token,
    required this.maxDaveProtocolVersion,
  });

  /// The voice server host, as given by `VOICE_SERVER_UPDATE` (no scheme or
  /// path - just `host[:port]`).
  final String endpoint;
  final Snowflake guildId;
  final Snowflake userId;
  final String sessionId;
  final String token;

  /// The highest DAVE protocol version this client supports - from
  /// `daveMaxSupportedProtocolVersion()` in the `dave` package. 0 means no
  /// DAVE support.
  final int maxDaveProtocolVersion;

  /// Voice gateway version. v8 is the minimum with resuming support and
  /// binary DAVE opcode sequence numbers; see
  /// https://docs.discord.food/topics/voice-connections.
  static const _gatewayVersion = 8;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _heartbeatTimer;
  bool _lastHeartbeatAcked = true;
  bool _closing = false;

  /// The last sequence number seen on a binary (DAVE) server->client
  /// message, sent back as `seq_ack` on heartbeats per gateway v8+.
  int? _lastBinarySequence;

  final _readyController = StreamController<VoiceReady>.broadcast();
  final _sessionDescriptionController = StreamController<VoiceSessionDescription>.broadcast();
  final _closeController = StreamController<VoiceGatewayClose>.broadcast();
  final _davePrepareTransitionController = StreamController<DavePrepareTransition>.broadcast();
  final _daveExecuteTransitionController = StreamController<DaveExecuteTransition>.broadcast();
  final _davePrepareEpochController = StreamController<DavePrepareEpoch>.broadcast();
  final _daveExternalSenderPackageController = StreamController<DaveExternalSenderPackage>.broadcast();
  final _daveProposalsController = StreamController<DaveProposals>.broadcast();
  final _daveAnnounceCommitTransitionController = StreamController<DaveAnnounceCommitTransition>.broadcast();
  final _daveWelcomeController = StreamController<DaveWelcome>.broadcast();
  final _clientsConnectController = StreamController<VoiceClientsConnect>.broadcast();
  final _clientDisconnectController = StreamController<VoiceClientDisconnect>.broadcast();
  final _speakingController = StreamController<VoiceSpeakingUpdate>.broadcast();
  final _videoController = StreamController<VoiceVideoUpdate>.broadcast();

  Stream<VoiceReady> get onReady => _readyController.stream;
  Stream<VoiceSessionDescription> get onSessionDescription => _sessionDescriptionController.stream;

  /// Fires when the underlying websocket closes unexpectedly (i.e. not as a
  /// result of calling [close] on this side - see the ordering note there).
  Stream<VoiceGatewayClose> get onClose => _closeController.stream;

  Stream<DavePrepareTransition> get onDavePrepareTransition => _davePrepareTransitionController.stream;
  Stream<DaveExecuteTransition> get onDaveExecuteTransition => _daveExecuteTransitionController.stream;
  Stream<DavePrepareEpoch> get onDavePrepareEpoch => _davePrepareEpochController.stream;
  Stream<DaveExternalSenderPackage> get onDaveExternalSenderPackage =>
      _daveExternalSenderPackageController.stream;
  Stream<DaveProposals> get onDaveProposals => _daveProposalsController.stream;
  Stream<DaveAnnounceCommitTransition> get onDaveAnnounceCommitTransition =>
      _daveAnnounceCommitTransitionController.stream;
  Stream<DaveWelcome> get onDaveWelcome => _daveWelcomeController.stream;
  Stream<VoiceClientsConnect> get onClientsConnect => _clientsConnectController.stream;
  Stream<VoiceClientDisconnect> get onClientDisconnect => _clientDisconnectController.stream;
  Stream<VoiceSpeakingUpdate> get onSpeaking => _speakingController.stream;

  /// Remote participants' video on/off state (opcode 12) - see
  /// [VoiceVideoUpdate]'s doc. This is how video actually turns on mid-call,
  /// not a second SDP exchange.
  Stream<VoiceVideoUpdate> get onVideo => _videoController.stream;

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

  void _sendJson(VoiceOpcode opcode, Object? data) {
    debugPrint('VoiceGateway: -> ${opcode.name} (${opcode.value})');
    _channel?.sink.add(jsonEncode({'op': opcode.value, 'd': data}));
  }

  /// Sends a binary DAVE opcode. Client-to-server binary messages are just
  /// `[1-byte opcode][payload]` - no sequence number (that's server->client
  /// only, on v8+).
  void _sendBinary(VoiceOpcode opcode, Uint8List payload) {
    debugPrint('VoiceGateway: -> ${opcode.name} (${opcode.value}) [binary, ${payload.length}B]');
    final frame = Uint8List(1 + payload.length);
    frame[0] = opcode.value;
    frame.setAll(1, payload);
    _channel?.sink.add(frame);
  }

  void _handleMessage(dynamic raw) {
    if (raw is String) {
      _handleJsonMessage(raw);
    } else if (raw is List<int>) {
      _handleBinaryMessage(Uint8List.fromList(raw));
    } else {
      debugPrint('VoiceGateway: received message of unexpected type ${raw.runtimeType}');
    }
  }

  void _handleJsonMessage(String raw) {
    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(raw) as Map<String, dynamic>;
    } catch (error) {
      debugPrint('VoiceGateway: failed to decode JSON payload: $error\nraw: $raw');
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
        case VoiceOpcode.speaking:
          final map = data as Map<String, dynamic>;
          final speakingUserId = map['user_id'] as String?;
          if (speakingUserId != null) {
            _speakingController.add(VoiceSpeakingUpdate(
              userId: speakingUserId,
              ssrc: map['ssrc'] as int,
              speaking: map['speaking'] as int,
            ));
          }
        case VoiceOpcode.video:
          _videoController.add(VoiceVideoUpdate.fromJson(data as Map<String, dynamic>));
        case VoiceOpcode.resumed:
          debugPrint('VoiceGateway: resumed session');
        case VoiceOpcode.davePrepareTransition:
          final map = data as Map<String, dynamic>;
          _davePrepareTransitionController.add(DavePrepareTransition(
            protocolVersion: map['protocol_version'] as int,
            transitionId: map['transition_id'] as int,
          ));
        case VoiceOpcode.daveExecuteTransition:
          final map = data as Map<String, dynamic>;
          _daveExecuteTransitionController.add(DaveExecuteTransition(
            transitionId: map['transition_id'] as int,
          ));
        case VoiceOpcode.davePrepareEpoch:
          final map = data as Map<String, dynamic>;
          _davePrepareEpochController.add(DavePrepareEpoch(
            protocolVersion: map['protocol_version'] as int,
            epoch: map['epoch'] as int,
          ));
        case VoiceOpcode.clientsConnect:
          final map = data as Map<String, dynamic>;
          _clientsConnectController.add(
            VoiceClientsConnect((map['user_ids'] as List).cast<String>()),
          );
        case VoiceOpcode.clientDisconnect:
          final map = data as Map<String, dynamic>;
          _clientDisconnectController.add(
            VoiceClientDisconnect(map['user_id'] as String),
          );
        default:
          debugPrint('VoiceGateway: unhandled JSON opcode ${payload['op']}: $data');
      }
    } catch (error, stackTrace) {
      debugPrint('VoiceGateway: error handling JSON opcode ${payload['op']}: $error\n$stackTrace');
    }
  }

  void _handleBinaryMessage(Uint8List data) {
    // Server-to-client binary messages on gateway v8+ are prefixed with a
    // 2-byte big-endian sequence number, then the 1-byte opcode.
    if (data.length < 3) {
      debugPrint('VoiceGateway: binary message too short (${data.length}B)');
      return;
    }
    final view = ByteData.sublistView(data);
    final sequence = view.getUint16(0, Endian.big);
    _lastBinarySequence = sequence;
    final opcode = VoiceOpcode.fromValue(data[2]);
    final payload = Uint8List.sublistView(data, 3);

    debugPrint('VoiceGateway: <- ${opcode?.name ?? data[2]} (binary, seq=$sequence, ${payload.length}B)');

    try {
      switch (opcode) {
        case VoiceOpcode.daveMlsExternalSenderPackage:
          _daveExternalSenderPackageController.add(DaveExternalSenderPackage(payload));
        case VoiceOpcode.daveMlsProposals:
          _daveProposalsController.add(DaveProposals(payload));
        case VoiceOpcode.daveMlsAnnounceCommitTransition:
          if (payload.length < 2) {
            throw const FormatException('MLS Announce Commit Transition payload too short');
          }
          _daveAnnounceCommitTransitionController.add(DaveAnnounceCommitTransition(
            transitionId: ByteData.sublistView(payload).getUint16(0, Endian.big),
            commitData: Uint8List.sublistView(payload, 2),
          ));
        case VoiceOpcode.daveMlsWelcome:
          if (payload.length < 2) {
            throw const FormatException('MLS Welcome payload too short');
          }
          _daveWelcomeController.add(DaveWelcome(
            transitionId: ByteData.sublistView(payload).getUint16(0, Endian.big),
            welcomeData: Uint8List.sublistView(payload, 2),
          ));
        default:
          debugPrint('VoiceGateway: unhandled binary opcode ${data[2]}');
      }
    } catch (error, stackTrace) {
      debugPrint('VoiceGateway: error handling binary opcode ${data[2]}: $error\n$stackTrace');
    }
  }

  void _identify() {
    _sendJson(VoiceOpcode.identify, {
      'server_id': guildId.toString(),
      'user_id': userId.toString(),
      'session_id': sessionId,
      'token': token,
      if (maxDaveProtocolVersion > 0) 'max_dave_protocol_version': maxDaveProtocolVersion,
      // Requests video capability up front, once, for the whole call -
      // per https://docs.discord.food/topics/voice-connections this is the
      // *only* place video gets negotiated in SDP terms; the server replies
      // with pre-allocated send SSRCs in Ready.streams (see
      // [VoiceReadyStream]), and turning the camera on/off later is just
      // [sendVideo] (opcode 12), no further SDP exchange. A single
      // non-simulcast layer ("100" = full quality) is all this client
      // offers - simulcast (multiple `rid`/quality layers) isn't used here.
      'video': true,
      'streams': [
        {'type': 'video', 'rid': '100', 'quality': 100},
      ],
    });
  }

  void _startHeartbeating(Duration interval) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(interval, (_) {
      if (!_lastHeartbeatAcked) {
        debugPrint('VoiceGateway: heartbeat was not acked; connection may be dead');
      }
      _lastHeartbeatAcked = false;
      _sendJson(VoiceOpcode.heartbeat, {
        't': DateTime.now().millisecondsSinceEpoch,
        if (_lastBinarySequence != null) 'seq_ack': _lastBinarySequence,
      });
    });
  }

  /// Sends Select Protocol (opcode 1) for the UDP transport, with the
  /// externally-discovered [address]/[port] (see `buildIpDiscoveryRequest`)
  /// and the chosen transport encryption [mode] (see
  /// `pickTransportEncryptionMode`).
  void selectUdpProtocol({required String address, required int port, required String mode}) {
    _sendJson(VoiceOpcode.selectProtocol, {
      'protocol': 'udp',
      'data': {
        'address': address,
        'port': port,
        'mode': mode,
      },
      'rtc_connection_id': _generateUuidV4(),
      'codecs': [
        {
          'name': 'opus',
          'type': 'audio',
          'priority': 1000,
          'payload_type': 120,
        },
      ],
    });
  }

  /// Sends Select Protocol (opcode 1) for the WebRTC transport (real
  /// ICE/DTLS/SRTP via `flutter_webrtc_rs`, as opposed to [selectUdpProtocol]'s
  /// raw-UDP-plus-Discord's-own-transport-encryption scheme), with
  /// [sdpFragment] built from the local offer - see
  /// `VoiceWebRtcRsSession.createOfferAndBuildFragment`.
  ///
  /// **Confirmed working for audio** against a live Discord voice server.
  /// [videoPayloadType] should be H264's payload type from the local offer
  /// (see `VoiceWebRtcRsSession`'s video support) so the SFU knows to expect
  /// H264 - per the docs, this `codecs` array is what actually determines
  /// the negotiated video codec; the SDP fragment's own rtpmap lines never
  /// mention H264 at all (see `_fragmentAttributePattern`'s doc in
  /// `voice_webrtc_rs_session.dart`), and *omitting this array entirely* is
  /// silently accepted but makes Discord fall back to assuming H264 with no
  /// specific payload type - which mismatches whatever payload type our own
  /// offer actually used, so video never gets recognized. Pass null only for
  /// an audio-only connection.
  ///
  /// [opusPayloadType]/[videoPayloadType]/[videoRtxPayloadType] must be the
  /// exact dynamic payload type numbers webrtc-rs assigned in [sdpFragment]'s
  /// own `a=rtpmap` lines (parse them out of the same offer rather than
  /// hardcoding a guess - they aren't guaranteed stable across webrtc-rs
  /// versions) - Discord treats this `codecs` array as authoritative for
  /// payload-type mapping, so a mismatch here silently misroutes media even
  /// though signaling itself succeeds.
  void selectWebRtcProtocol(
    String sdpFragment, {
    required int opusPayloadType,
    int? videoPayloadType,
    int? videoRtxPayloadType,
  }) {
    _sendJson(VoiceOpcode.selectProtocol, {
      'protocol': 'webrtc',
      // Confirmed against a real client's own socket traffic (captured live
      // in this channel): `data` is the raw fragment *string* directly, not
      // `{"sdp": fragment}` as this sent before - and there's a separate,
      // redundant top-level `sdp` field carrying the identical string
      // alongside it. Docs describe `data` as "?protocol data | string"
      // without spelling out which one WebRTC mode actually uses; the real
      // client's traffic is unambiguous.
      'data': sdpFragment,
      'sdp': sdpFragment,
      'rtc_connection_id': _generateUuidV4(),
      'codecs': [
        {
          'name': 'opus',
          'type': 'audio',
          'priority': 1000,
          'payload_type': opusPayloadType,
        },
        if (videoPayloadType != null)
          {
            'name': 'H264',
            'type': 'video',
            'priority': 1000,
            'payload_type': videoPayloadType,
            if (videoRtxPayloadType != null) 'rtx_payload_type': videoRtxPayloadType,
          },
      ],
    });
  }

  /// Sends a Speaking (opcode 5) update. [ssrc] should be the value from
  /// [VoiceReady.ssrc].
  void setSpeaking({required int ssrc, required bool speaking}) {
    _sendJson(VoiceOpcode.speaking, {
      'speaking': speaking ? 1 : 0,
      'delay': 0,
      'ssrc': ssrc,
    });
  }

  /// Turns this client's video on/off (opcode 12) - see [VoiceVideoUpdate]'s
  /// doc for why this, and not a second Select Protocol call, is how camera
  /// on/off works mid-call. [videoSsrc]/[rtxSsrc] must be the SSRCs the
  /// server assigned for this stream in Ready (see [VoiceReadyStream]), not
  /// freely chosen - the whole point is that they were already negotiated
  /// once, up front.
  ///
  /// [quality]/[maxBitrateBps]/[maxFramerate]/[maxWidth]/[maxHeight] mirror
  /// what a real Discord client actually sends here (captured live from the
  /// web client's own socket traffic - `docs.discord.food`'s example omits
  /// them, marking the underlying fields optional, but the real client
  /// always includes them). Passing only `type`/`rid`/`ssrc`/`active`, as
  /// this method previously did, still gets acknowledged with no error -
  /// but the video was never relayed to any other client, official or
  /// otherwise, suggesting the server uses these extra fields to actually
  /// register the stream as valid before treating it as live, rather than
  /// silently defaulting them.
  void sendVideo({
    required int audioSsrc,
    required int videoSsrc,
    int? rtxSsrc,
    required bool active,
    String rid = '100',
    int quality = 100,
    int maxBitrateBps = 2500000,
    int maxFramerate = 30,
    required int maxWidth,
    required int maxHeight,
  }) {
    _sendJson(VoiceOpcode.video, {
      'audio_ssrc': audioSsrc,
      'video_ssrc': videoSsrc,
      if (rtxSsrc != null) 'rtx_ssrc': rtxSsrc,
      'streams': [
        {
          'type': 'video',
          'rid': rid,
          'ssrc': videoSsrc,
          'active': active,
          'quality': quality,
          if (rtxSsrc != null) 'rtx_ssrc': rtxSsrc,
          'max_bitrate': maxBitrateBps,
          'max_framerate': maxFramerate,
          'max_resolution': {'type': 'fixed', 'width': maxWidth, 'height': maxHeight},
        },
      ],
    });
  }

  /// `dave_protocol_ready_for_transition` (opcode 23, JSON). Sent once local
  /// state for [transitionId] (an MLS commit/welcome having been applied,
  /// or a protocol downgrade being ready) has been prepared.
  void sendDaveTransitionReady(int transitionId) {
    _sendJson(VoiceOpcode.daveTransitionReady, {'transition_id': transitionId});
  }

  /// `dave_mls_key_package` (opcode 26, binary). [keyPackage] is
  /// `DaveSession.marshalledKeyPackage`.
  void sendDaveKeyPackage(Uint8List keyPackage) {
    _sendBinary(VoiceOpcode.daveMlsKeyPackage, keyPackage);
  }

  /// `dave_mls_commit_welcome` (opcode 28, binary). [commitWelcome] is the
  /// output of `DaveSession.processProposals`.
  void sendDaveCommitWelcome(Uint8List commitWelcome) {
    _sendBinary(VoiceOpcode.daveMlsCommitWelcome, commitWelcome);
  }

  /// `dave_mls_invalid_commit_welcome` (opcode 31, JSON). Sent when a
  /// received commit/welcome for [transitionId] couldn't be processed -
  /// asks the voice server to remove and re-add this member so it can
  /// recover with a fresh key package.
  void sendDaveInvalidCommitWelcome(int transitionId) {
    _sendJson(VoiceOpcode.daveMlsInvalidCommitWelcome, {'transition_id': transitionId});
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
    await _davePrepareTransitionController.close();
    await _daveExecuteTransitionController.close();
    await _davePrepareEpochController.close();
    await _daveExternalSenderPackageController.close();
    await _daveProposalsController.close();
    await _daveAnnounceCommitTransitionController.close();
    await _daveWelcomeController.close();
    await _clientsConnectController.close();
    await _clientDisconnectController.close();
    await _speakingController.close();
    await _videoController.close();
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
