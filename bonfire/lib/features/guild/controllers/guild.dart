import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:collection/collection.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bonfire/features/me/controllers/settings.dart';

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
