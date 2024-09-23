import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bonfire/features/me/controllers/settings.dart';

part 'guild.g.dart';

/// Fetches the current guild from [guildid].
@Riverpod(keepAlive: true)
class GuildController extends _$GuildController {
  Guild? guild;

  @override
  Future<Guild?> build(Snowflake guildId) async {
    var auth = ref.watch(authProvider.notifier).getAuth();

    if (guildId.isZero) {
      // If the guildId is zero, we are at @me (probably, idk if there's a better way to do this)
      return null;
    }

    if (auth is AuthUser) {
      var guilds = ref.watch(guildsStateProvider).valueOrNull;
      if (guilds == null) return null;
      return guilds.where((element) => element.id == guildId).first;
    }

    return null;
  }
}
