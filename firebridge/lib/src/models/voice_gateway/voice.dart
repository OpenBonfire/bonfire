import 'package:firebridge/src/models/snowflake.dart';

class VoiceGatewayUser {
  final Snowflake serverId;
  final Snowflake userId;
  final String sessionId;
  final String token;
  final int maxSecureFramesVersion;
  final bool video;
  // TODO: add streams class
  final List<dynamic> streams;

  VoiceGatewayUser({
    required this.serverId,
    required this.userId,
    required this.sessionId,
    required this.token,
    required this.maxSecureFramesVersion,
    required this.video,
    required this.streams,
  });
}
