import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/guild/controllers/current_guild.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guild_members.g.dart';

@riverpod
class GuildMembers extends _$GuildMembers {
  AuthUser? user;

  @override
  Future<List<Member>> build() async {
    final currentGuild = ref.watch(currentGuildControllerProvider);
    var authOutput = ref.watch(authProvider.notifier).getAuth();

    return [];
  }
}
