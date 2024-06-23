import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member.g.dart';

@riverpod
Future<Member?> getMember(GetMemberRef ref, Snowflake memberId) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();
  var currentGuild = ref.read(guildControllerProvider);

  if (authOutput is AuthUser) {
    return await authOutput.client.guilds[currentGuild!.id].members.get(memberId);
  }
}

@riverpod Future<List<Role?>?> getGuildRoles(GetGuildRolesRef ref) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();
  var currentGuild = ref.read(guildControllerProvider);

  if (authOutput is AuthUser) {
    return await authOutput.client.guilds[currentGuild!.id].roles.list();
  }
}