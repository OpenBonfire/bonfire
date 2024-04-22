import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/shared/models/guild.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';

part 'current_guild.g.dart';

@riverpod
class CurrentGuildController extends _$CurrentGuildController {
  List<Guild> guilds = [];

  @override
  Guild? build() {
    var guildController = ref.watch(guildControllerProvider);
    var guildsOutput = ref.read(guildsProvider);
    print(guildController);
    guildsOutput.when(
      data: (newGuilds) {
        guilds = newGuilds;
      },
      error: (data, trace) {},
      loading: () {},
    );

    return guilds.firstWhereOrNull((element) => element.id == guildController);
  }
}
