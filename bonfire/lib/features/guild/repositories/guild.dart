import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guild.g.dart';

@Riverpod(keepAlive: true)
Future<Uri?> guildBannerUrl(GuildBannerUrlRef ref, Snowflake guildId) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();

  if (authOutput is AuthUser) {
    // (await authOutput.client.guilds.get(guildId)).rulesChannel
    return (await authOutput.client.guilds.get(guildId)).banner?.url;
  }

  return null;
}
