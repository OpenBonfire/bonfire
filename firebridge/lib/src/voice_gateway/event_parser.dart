import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/models/voice_gateway/event.dart';
import 'package:firebridge/src/models/voice_gateway/opcode.dart';

/// Handles all connections to do with voice and video calling that are not present in the main gateway.
mixin class VoiceEventParser {
  VoiceGatewayEvent parseVoiceGatewayEvent(Map<String, Object?> raw) {
    final mapping = {
      VoiceOpcode.ready.value: parseReady,
      VoiceOpcode.selectProtocol.value: parseSelectProtocol,
      VoiceOpcode.heartbeat.value: parseHeartbeat,
      VoiceOpcode.hello.value: parseHello,
      VoiceOpcode.resumed.value: parseResumed,
      VoiceOpcode.sessionDescription.value: parseSessionDescription,
      VoiceOpcode.sessionUpdate.value: parseSessionUpdate,
      VoiceOpcode.speaking.value: parseSpeaking,
      VoiceOpcode.clientDisconnect.value: parseClientDisconnect,
      VoiceOpcode.voiceBackendVersion.value: parseBackendVersion,
    };

    return mapping[raw['op'] as int]!(raw);
  }

  VoiceSelectProtocolEvent parseSelectProtocol(Map<String, Object?> raw) {
    print("SELECT PROTOCOLO1");
    var data = raw['d'] as Map<String, Object?>;
    return VoiceSelectProtocolEvent(
      protocol: data['protocol'] as String,
      data: data['data'] as String,
      rtcConnectionId: data['rtc_connection_id'] as String?,
      codecs: (data['codecs'] as List?)?.cast<Map<String, Object?>>(),
      experiments: (data['experiments'] as List?)?.cast<String>(),
    );
  }

  VoiceHelloEvent parseHello(Map<String, Object?> raw) {
    return VoiceHelloEvent(
      heartbeatInterval:
          (raw['d'] as Map<String, dynamic>)['heartbeat_interval'] as int,
      gatewayVersion: raw['v'] as int?,
    );
  }

  VoiceHeartbeatEvent parseHeartbeat(Map<String, Object?> raw) {
    return VoiceHeartbeatEvent();
  }

  VoiceReadyEvent parseReady(Map<String, Object?> raw) {
    var data = raw['d'] as Map<String, Object?>;
    return VoiceReadyEvent(
      ssrc: data['ssrc'] as int,
      ip: data['ip'] as String,
      port: data['port'] as int,
      modes: (data['modes'] as List).cast<String>(),
      experiments: (raw['experiments'] as List?)?.cast<String>(),
      streams: (data['streams'] as List).cast<Map<String, Object?>>(),
    );
  }

  VoiceResumedEvent parseResumed(Map<String, Object?> raw) {
    var data = raw['d'] as Map<String, Object?>;
    return VoiceResumedEvent(
      serverId: data['server_id'] as String,
      sessionId: data['session_id'] as String,
      token: data['token'] as String,
    );
  }

  VoiceSessionDescriptionEvent parseSessionDescription(
      Map<String, Object?> raw) {
    var data = raw['d'] as Map<String, Object?>;
    return VoiceSessionDescriptionEvent(
      audioCodec: data['audio_codec'] as String,
      videoCodec: data['video_codec'] as String,
      mediaSessionId: data['media_session_id'] as String,
      mode: data['mode'] as String?,
      secretKey: (data['secret_key'] as List<int>?)?.cast<int>(),
      sdp: data['sdp'] as String?,
      keyframeInterval: data['keyframe_interval'] as int?,
    );
  }

  VoiceSessionUpdateEvent parseSessionUpdate(Map<String, Object?> raw) {
    var data = raw['d'] as Map<String, Object?>;
    return VoiceSessionUpdateEvent(
      audioCodec: data['audio_codec'] as String?,
      videoCodec: data['video_codec'] as String?,
      mediaSessionId: data['media_session_id'] as String?,
    );
  }

  VoiceSpeakingEvent parseSpeaking(Map<String, Object?> raw) {
    var data = raw['d'] as Map<String, Object?>;
    return VoiceSpeakingEvent(
      speaking: data['speaking'] as bool,
      ssrc: data['ssrc'] as int,
      userId: Snowflake.parse(data['user_id']!),
      delay: data['delay'] as int?,
    );
  }

  VoiceClientDisconnectEvent parseClientDisconnect(Map<String, Object?> raw) {
    var data = raw['d'] as Map<String, Object?>;
    return VoiceClientDisconnectEvent(
      userId: Snowflake.parse(data['user_id']!),
    );
  }

  VoiceBackendVersionEvent parseBackendVersion(Map<String, Object?> raw) {
    var data = raw['d'] as Map<String, Object?>;
    return VoiceBackendVersionEvent(
      voice: data['voice'] as String,
      rtcWorker: data['rtc_worker'] as String,
    );
  }
}
