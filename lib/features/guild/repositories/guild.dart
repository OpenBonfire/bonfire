import 'dart:typed_data';

import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guild.g.dart';

final _guildIconCache = CacheManager(Config(
  'icon_cache',
  maxNrOfCacheObjects: 10000,
));

@Riverpod(keepAlive: true)
Future<Uri?> guildBannerUrl(GuildBannerUrlRef ref, Snowflake guildId) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();

  if (authOutput is AuthUser) {
    // (await authOutput.client.guilds.get(guildId)).rulesChannel
    return (await authOutput.client.guilds.get(guildId)).banner?.url;
  }

  return null;
}

@Riverpod(keepAlive: true)
Future<Uint8List?> guildIcon(GuildIconRef ref, Snowflake guildId) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();
  if (authOutput is AuthUser) {
    CdnAsset? iconAsset = (await authOutput.client.guilds.get(guildId)).icon;
    if (iconAsset == null) return null;

    // FileInfo? fromCache =
    //     await _guildIconCache.getFileFromCache(iconAsset.hash);

    Uint8List? bytes;

    // if (fromCache != null) {
    //   bytes = await fromCache.file.readAsBytes();
    // } else {
    bytes = await iconAsset.fetch();
    _guildIconCache.putFile(iconAsset.hash, bytes);
    // }

    return bytes;
  }

  return null;
}
