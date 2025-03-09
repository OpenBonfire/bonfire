import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guild.g.dart';

/// Fetches the current guild from [guildid].
@Riverpod(keepAlive: true)
class GuildController extends _$GuildController {
  Guild? guild;

  @override
  Guild? build(Snowflake guildId) {
    if (guildId.isZero) {
      // If the guildId is zero, we are at @me (probably, idk if there's a better way to do this)
      return null;
    }

    return null;
  }

  void setGuild(Guild guild) {
    state = guild;
  }
}
