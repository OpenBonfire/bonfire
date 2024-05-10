import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/shared/models/guild.dart';
import 'package:flutter/widgets.dart';
import 'package:firebridge/firebridge.dart' as firebridge;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

part 'guilds.g.dart';

/*
TODO: We can cache each guild by instantly returning the last value,
then setting `state` when the actual value is recieved.
*/

@riverpod
class Guilds extends _$Guilds {
  AuthUser? user;
  List<Guild> guilds = [];

  final _cacheManager = CacheManager(
    Config(
      'guilds',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 10000,
    ),
  );

  @override
  Future<List<Guild>> build() async {
    var authOutput = ref.read(authProvider.notifier).getAuth();

    if ((authOutput != null) & (authOutput! is AuthUser)) {
      user = authOutput as AuthUser;

      List<firebridge.UserGuild> userGuilds = await user!.client.listGuilds();
      List<Future<Guild>> guildFutures = userGuilds.map((guild) async {
        // Async icon lookup for speed
        // guild.fetchPreview();
        var iconImage;
        if (guild.icon != null) {
          var cacheData =
              await _cacheManager.getFileFromCache(guild.icon!.hash);
          if (cacheData != null) {
            var iconBytes = cacheData.file.readAsBytesSync();
            iconImage = Image.memory(iconBytes);
          } else {
            var iconBytes = await guild.icon!.fetch();
            iconImage = Image.memory(iconBytes);
            _cacheManager.putFile(guild.icon!.hash, iconBytes);
          }
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
