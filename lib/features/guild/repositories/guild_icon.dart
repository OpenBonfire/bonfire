import 'dart:typed_data';

import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guild_icon.g.dart';

final iconCache = CacheManager(
  Config(
    'guild_icons',
    // stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 200,
  ),
);

@Riverpod(keepAlive: true)
Future<Uint8List?> guildIcon(GuildIconRef ref, Snowflake guildId) async {
  var user = ref.watch(authProvider.notifier).getAuth();
  if (user is! AuthUser) return Uint8List(0);

  Guild guild = ref.watch(guildsStateProvider)!.firstWhereOrNull(
        (element) => element.id == guildId,
      )!;

  if (guild.icon == null) return null;
  Uint8List? fromCache =
      await (await iconCache.getFileFromCache(guild.iconHash!))
          ?.file
          .readAsBytes();

  if (fromCache != null) {
    return fromCache;
  }

  Uint8List? icon = await guild.icon?.fetch();
  if (guild.iconHash != null && icon != null) {
    iconCache.putFile(guild.iconHash!, icon);
  }

  return icon;
}
