import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:firebridge/firebridge.dart';

part 'guild.g.dart';

@riverpod
class GuildController extends _$GuildController {
  UserGuild? guild;
  List<UserGuild> guilds = [];

  @override
  UserGuild? build() {
    var guildOutput = ref.watch(guildsProvider);
    guildOutput.when(
        data: (newGuilds) {
          guilds = newGuilds;
        },
        error: (data, trace) {},
        loading: () {});

    return guild;
  }

  UserGuild setGuild(UserGuild newGuild) {
    guild = newGuild;
    state = guild!;
    return state!;
  }

  // get current guild
  UserGuild? get currentGuild {
    return guild;
  }
}
