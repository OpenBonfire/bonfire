import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guilds.g.dart';

@Riverpod(keepAlive: true)
class Guilds extends _$Guilds {
  @override
  Future<List<UserGuild>> build() async {
    final client = ref.watch(clientControllerProvider) as AuthUser;
    List<UserGuild> userGuilds = await client.client.listGuilds();
    return userGuilds;
  }
}
