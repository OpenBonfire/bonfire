import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/shared/models/guild.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channels.g.dart';

@riverpod
class Channels extends _$Channels {
  int? guildId;
  List<Guild> guilds = [];

  @override
  int? build() {
    /*
    Get guilds from client, then return response.
    We can also do an initial `state =` when pulling from cache
    */
    var guildOutput = ref.watch(guildsProvider);

    return guildId;
  }
}
