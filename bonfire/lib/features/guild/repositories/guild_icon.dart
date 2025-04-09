import 'dart:typed_data';

import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guild_icon.g.dart';

@Riverpod(keepAlive: true)
Future<Uint8List?> guildIcon(Ref ref, Snowflake guildId) async {
  var user = ref.watch(authProvider.notifier).getAuth();
  if (user is! AuthUser) return null;

  Guild guild = ref.watch(guildControllerProvider(guildId))!;

  if (guild.icon == null) return null;
  // Uint8List? fromCache =
  //     await (await iconCache.getFileFromCache(guild.iconHash!))
  //         ?.file
  //         .readAsBytes();

  // if (fromCache != null) {
  //   return fromCache;
  // }

  Uint8List? icon = await guild.icon?.fetch();
  // if (guild.iconHash != null && icon != null) {
  //   iconCache.putFile(guild.iconHash!, icon);
  // }

  return icon;
}
