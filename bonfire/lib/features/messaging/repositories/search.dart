import 'package:bonfire/features/authenticator/data/repositories/auth.dart';
import 'package:bonfire/features/authenticator/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search.g.dart';

@Riverpod(keepAlive: true)
class MessageSearch extends _$MessageSearch {
  AuthUser? user;

  @override
  Future<List<Message>?> build(Snowflake guildId, String query) async {
    final auth = ref.watch(authProvider.notifier).getAuth();
    if (auth is AuthUser) user = auth;

    return user!.client.guilds[guildId].manager.searchMessages(guildId, query);
  }
}
