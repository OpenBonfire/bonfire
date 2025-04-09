import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guild.g.dart';

@Riverpod(keepAlive: true)
Future<Uri?> guildBannerUrl(Ref ref, Snowflake guildId) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();

  if (authOutput is AuthUser) {
    // (await authOutput.client.guilds.get(guildId)).rulesChannel
    return (await authOutput.client.guilds.get(guildId)).banner?.url;
  }

  return null;
}
