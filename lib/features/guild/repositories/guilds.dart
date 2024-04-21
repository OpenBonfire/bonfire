import 'dart:typed_data';

import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/shared/models/guild.dart';
import 'package:flutter/widgets.dart';
import 'package:nyxx_self/nyxx.dart' as nyxx;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guilds.g.dart';

/*
TODO: We can cache each guild by instantly returning the last value,
then setting `state` when the actual value is recieved.
*/

@riverpod
class Guilds extends _$Guilds {
  AuthUser? user;
  List<Guild> guilds = [];

  @override
  Future<List<Guild>> build() async {
    var authOutput = ref.read(authProvider.notifier).getAuth();

    if ((authOutput != null) & (authOutput! is AuthUser)) {
      user = authOutput as AuthUser;

      List<nyxx.UserGuild> userGuilds = await user!.client.listGuilds();
      List<Future<Guild>> guildFutures = userGuilds.map((guild) async {
        // Async icon lookup for speed
        var iconImage;
        if (guild.icon != null) {
          var iconBytes = await guild.icon!.fetch();
          iconImage = Image.memory(iconBytes);
        }
        return Guild(
          id: guild.id.value,
          name: guild.name,
          icon: iconImage,
        );
      }).toList();

      // Wait for all guilds to be fetched concurrently
      List<Guild> fetchedGuilds = await Future.wait(guildFutures);
      return fetchedGuilds;
    } else {
      print("Not an auth user. This is probably very bad.");
    }
    return guilds;
  }
}
