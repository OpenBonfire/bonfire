import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/shared/models/guild.dart';
import 'package:flutter/widgets.dart';
import 'package:nyxx_self/nyxx.dart' as nyxx;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guilds.g.dart';

@riverpod
class Guilds extends _$Guilds {
  AuthUser? user;
  List<Guild> guilds = [];

  @override
  Future<List<Guild>> build() async {
    var authOutput = ref.read(authProvider.notifier).getAuth();

    if ((authOutput != null) & (authOutput! is AuthUser)) {
      List<nyxx.UserGuild> guilds =
          await user!.client.guilds.client.listGuilds();

      List<Guild> _guilds = [];
      for (nyxx.UserGuild guild in guilds) {
        _guilds.add(Guild(
            id: guild.id.value,
            name: guild.name,
            // todo: pull images from flutter cache
            icon: Image.memory(await guild.icon!.fetch())));
      }
    } else {
      print("Not an auth user. This is probably very bad.");
    }
    return guilds;
  }
}
