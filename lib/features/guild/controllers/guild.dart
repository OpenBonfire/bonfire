import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guild.g.dart';

/// Fetches the current guild from [guildid].
@riverpod
class GuildController extends _$GuildController {
  Guild? guild;

  @override
  Future<Guild?> build(guildId) async {
    var auth = ref.watch(authProvider.notifier).getAuth();

    if (guildId == "@me") {
      /*
      Not sure if this is the best way to do this

      If the guild is ever null, I *think* we can assume 100% of the time to
      assume we are in the user profile. Please inform me if you find any 
      exceptions to this assumption.
      */
      return null;
    }

    Snowflake guild = Snowflake(int.parse(guildId));

    if (auth is AuthUser) {
      return await auth.client.guilds.get(guild);
    }

    return null;
  }
}
