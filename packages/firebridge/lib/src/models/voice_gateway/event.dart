import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/models/voice_gateway/opcode.dart';
import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

/// {@template gateway_event}
/// The base class for all events received from the Voice Gateway.
/// {@endtemplate}
abstract class VoiceGatewayEvent with ToStringHelper {
  /// The opcode of this event.
  final VoiceOpcode opcode;

  /// {@macro gateway_event}
  /// @nodoc
  VoiceGatewayEvent({required this.opcode});
}

class VoiceHelloEvent extends VoiceGatewayEvent {
  final int heartbeatInterval;
  final int? gatewayVersion;

  VoiceHelloEvent({
    required this.heartbeatInterval,
    this.gatewayVersion,
  }) : super(opcode: VoiceOpcode.hello);
}

class VoiceSelectProtocolEvent extends VoiceGatewayEvent {
  final String protocol;
  final String data;
  final String? rtcConnectionId;
  final List<Map<String, Object?>>? codecs;
  final List<String>? experiments;

  VoiceSelectProtocolEvent({
    required this.protocol,
    required this.data,
    this.rtcConnectionId,
    this.codecs,
    this.experiments,
  }) : super(opcode: VoiceOpcode.selectProtocol);
}

/// {@template voice_ready_event}
/// Emitted when the client receives a voice ready event.
/// {@endtemplate}
class VoiceReadyEvent extends VoiceGatewayEvent {
  final int ssrc;
  final String ip;
  final int port;
  final List<String> modes;
  final List<Map<String, Object?>> streams;
  final List<String>? experiments;

  VoiceReadyEvent({
    required this.ssrc,
    required this.ip,
    required this.port,
    required this.modes,
    required this.streams,
    this.experiments,
  }) : super(opcode: VoiceOpcode.ready);
}

/// {@template heartbeat_event}
/// Emitted when the client receives a request to heartbeat.
/// {@endtemplate}
class VoiceHeartbeatEvent extends VoiceGatewayEvent {
  /// {@macro heartbeat_event}
  VoiceHeartbeatEvent() : super(opcode: VoiceOpcode.heartbeat);
}

/// {@template voice_resumed_event}
/// Emitted when the client receives a voice resumed event.
/// {@endtemplate}
class VoiceResumedEvent extends VoiceGatewayEvent {
  final String sessionId;
  final String token;
  final String serverId;

  VoiceResumedEvent({
    required this.sessionId,
    required this.token,
    required this.serverId,
  }) : super(opcode: VoiceOpcode.resume);
}

/// {@template voice_session_description_event}
/// Emitted when the client receives a voice session description event.
/// {@endtemplate}
class VoiceSessionDescriptionEvent extends VoiceGatewayEvent {
  /// The audio codec to use
  final String audioCodec;

  /// The video codec to use
  final String videoCodec;

  /// The media session ID, used for analytics
  final String mediaSessionId;

  /// The encryption mode to use, not applicable to WebRTC
  final String? mode;

  /// The 32 byte secret key used for encryption, not applicable to WebRTC
  final List<int>? secretKey;

  /// The WebRTC session description protocol
  final String? sdp;

  /// The keyframe interval in milliseconds
  final int? keyframeInterval;

  VoiceSessionDescriptionEvent({
    required this.audioCodec,
    required this.videoCodec,
    required this.mediaSessionId,
    this.mode,
    this.secretKey,
    this.sdp,
    this.keyframeInterval,
  }) : super(opcode: VoiceOpcode.sessionDescription);
}

/// {@template voice_session_update_event}
/// Emitted when the client receives a voice session update event.
/// {@endtemplate}
class VoiceSessionUpdateEvent extends VoiceGatewayEvent {
  /// The audio codec to use
  final String? audioCodec;

  /// The video codec to use
  final String? videoCodec;

  /// The media session ID, used for analytics
  final String? mediaSessionId;

  VoiceSessionUpdateEvent({
    this.audioCodec,
    this.videoCodec,
    this.mediaSessionId,
  }) : super(opcode: VoiceOpcode.sessionUpdate);
}

/// {@template speaking_event}
/// Emitted when the client recieves a speaking event.
/// {@endtemplate}
class VoiceSpeakingEvent extends VoiceGatewayEvent {
  /// The speaking flags
  final bool speaking;

  /// The SSRC of the speaking user
  final int ssrc;

  /// The user ID of the speaking user
  final Snowflake userId;

  /// The speaking packet delay
  final int? delay;

  VoiceSpeakingEvent({
    required this.speaking,
    required this.ssrc,
    required this.userId,
    this.delay,
  }) : super(opcode: VoiceOpcode.speaking);
}

/// {@template voice_client_connect_event}
/// Emitted when a user disconnects from a voice channel.
/// {@endtemplate}
class VoiceClientDisconnectEvent extends VoiceGatewayEvent {
  /// The ID of the user that disconnected
  final Snowflake userId;

  VoiceClientDisconnectEvent({
    required this.userId,
  }) : super(opcode: VoiceOpcode.clientDisconnect);
}

/// {@template voice_backend_version_event}
/// Emitted when the client receives a voice backend version event.
/// {@endtemplate}
class VoiceBackendVersionEvent extends VoiceGatewayEvent {
  final String voice;
  final String rtcWorker;

  VoiceBackendVersionEvent({
    required this.voice,
    required this.rtcWorker,
  }) : super(opcode: VoiceOpcode.voiceBackendVersion);
}
