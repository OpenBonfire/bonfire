import 'package:firebridge/src/builders/builder.dart';
import 'package:firebridge/src/builders/sentinels.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/models/voice/voice_identify.dart';
import 'package:firebridge/src/models/voice/voice_state.dart';

class VoiceStateUpdateBuilder extends UpdateBuilder<VoiceState> {
  Snowflake? channelId;

  bool? suppress;

  VoiceStateUpdateBuilder({this.channelId, this.suppress});

  @override
  Map<String, Object?> build() => {
        if (channelId != null) 'channel_id': channelId!.toString(),
        if (suppress != null) 'suppress': suppress,
      };
}

class CurrentUserVoiceStateUpdateBuilder extends VoiceStateUpdateBuilder {
  DateTime? requestToSpeakTimeStamp;

  CurrentUserVoiceStateUpdateBuilder(
      {super.channelId,
      super.suppress,
      this.requestToSpeakTimeStamp = sentinelDateTime});

  @override
  Map<String, Object?> build() => {
        ...super.build(),
        if (!identical(requestToSpeakTimeStamp, sentinelDateTime))
          'request_to_speak_timestamp':
              requestToSpeakTimeStamp?.toIso8601String(),
      };
}

class GatewayVoiceStateBuilder extends CreateBuilder<VoiceState> {
  Snowflake? channelId;

  bool isMuted;

  bool isDeafened;

  bool isStreaming;

  GatewayVoiceStateBuilder({
    required this.channelId,
    required this.isMuted,
    required this.isDeafened,
    required this.isStreaming,
  });

  @override
  Map<String, Object?> build() => {
        'channel_id': channelId?.toString(),
        'self_mute': isMuted,
        'self_deaf': isDeafened,
        'self_video': isStreaming,
      };
}

class VoiceIdentifyBuilder extends CreateBuilder<VoiceIdentify> {
  Snowflake guildId;

  Snowflake userId;

  String sessionId;

  String token;

  bool? video;

  VoiceIdentifyBuilder({
    required this.guildId,
    required this.userId,
    required this.sessionId,
    required this.token,
    this.video,
  });

  @override
  Map<String, Object?> build() => {
        'server_id': guildId.value.toString(),
        'user_id': userId.value.toString(),
        'session_id': sessionId,
        'token': token,
        'video': video ?? false,
        // 'streams': [],
      };
}
