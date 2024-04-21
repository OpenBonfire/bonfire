import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/shared/models/guild.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guild.g.dart';

@riverpod
class GuildController extends _$GuildController {
  int guildId = 0;
  List<Guild> guilds = [];

  @override
  int build() {
    var guildOutput = ref.watch(guildsProvider);
    guildOutput.when(
        data: (newGuilds) {
          print("updating guilds!");
          guilds = newGuilds;
        },
        error: (data, trace) {},
        loading: () {});

    return guildId;
  }

  int setGuild(int newGuildId) {
    guildId = newGuildId;
    state = guildId;
    return state;
  }
}
