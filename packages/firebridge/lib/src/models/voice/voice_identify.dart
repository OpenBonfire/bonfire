import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

class VoiceIdentify with ToStringHelper {
  /// The ID of the guild or private channel being connecting to
  final Snowflake guildId;

  /// The ID of the current user
  final Snowflake userId;

  /// The session ID of the current session
  final String sessionId;

  /// The voice token for the current session
  final String token;

  ///	Whether or not this connection supports video
  final bool? video;

  // I need to do more research on this
  // final List<StreamObject> streams;

  VoiceIdentify({
    required this.guildId,
    required this.userId,
    required this.sessionId,
    required this.token,
    this.video,
    // required this.streams,
  });
}
