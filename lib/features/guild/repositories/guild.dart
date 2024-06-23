import 'dart:typed_data';

import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guild.g.dart';

@riverpod
Future<Uri?> guildBannerUrl(GuildBannerUrlRef ref) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();
  var currentGuild = ref.watch(guildControllerProvider);

  if (authOutput is AuthUser) {
    return (await authOutput.client.guilds.get(currentGuild!.id)).banner?.url;
  }
}