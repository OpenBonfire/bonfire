import 'package:firebridge/src/cache/cache.dart';
import 'package:firebridge/src/client.dart';
import 'package:firebridge/src/http/request.dart';
import 'package:firebridge/src/http/route.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/models/voice/voice_region.dart';
import 'package:firebridge/src/models/voice/voice_state.dart';
import 'package:firebridge/src/utils/parsing_helpers.dart';

/// A manager for [VoiceState]s.
class VoiceManager {
  /// The client this manager belongs to.
  final NyxxRest client;

  /// The cache for voice states.
  @Deprecated('Use PartialGuild.voiceStates instead')
  final Cache<VoiceState> cache;

  /// Create a new [VoiceManager].
  // ignore: deprecated_member_use_from_same_package
  VoiceManager(this.client) : cache = Cache(client, 'voiceStates', client.options.voiceStateConfig);

  /// Parse a [VoiceState] from a [Map].
  VoiceState parseVoiceState(Map<String, Object?> raw, {Snowflake? guildId}) {
    guildId ??= maybeParse(raw['guild_id'], Snowflake.parse);
    final userId = Snowflake.parse(raw['user_id']!);

    return VoiceState(
      manager: this,
      guildId: guildId,
      channelId: maybeParse(raw['channel_id'], Snowflake.parse),
      userId: userId,
      member: maybeParse(raw['member'], (Map<String, Object?> raw) => client.guilds[guildId ?? Snowflake.zero].members.parse(raw, userId: userId)),
      sessionId: raw['session_id'] as String,
      isServerDeafened: raw['deaf'] as bool,
      isServerMuted: raw['mute'] as bool,
      isSelfDeafened: raw['self_deaf'] as bool,
      isSelfMuted: raw['self_mute'] as bool,
      isStreaming: raw['self_stream'] as bool? ?? false,
      isVideoEnabled: raw['self_video'] as bool,
      isSuppressed: raw['suppress'] as bool,
      requestedToSpeakAt: maybeParse(raw['request_to_speak_timestamp'], DateTime.parse),
    );
  }

  /// Parse a [VoiceRegion] from a [Map].
  VoiceRegion parseVoiceRegion(Map<String, Object?> raw) {
    return VoiceRegion(
      id: raw['id'] as String,
      name: raw['name'] as String,
      isOptimal: raw['optimal'] as bool,
      isDeprecated: raw['deprecated'] as bool,
      isCustom: raw['custom'] as bool,
    );
  }

  /// List all the available voice regions.
  Future<List<VoiceRegion>> listRegions() async {
    final route = HttpRoute()
      ..voice()
      ..regions();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(response.jsonBody as List, parseVoiceRegion);
  }
}
