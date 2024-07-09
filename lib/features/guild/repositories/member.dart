import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member.g.dart';

@Riverpod(keepAlive: true)
Future<Member?> getMember(
    GetMemberRef ref, Snowflake guildId, Snowflake memberId) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();

  if (authOutput is AuthUser) {
    return await authOutput.client.guilds[guildId].members.get(memberId);
  }
}

@Riverpod(keepAlive: true)
Future<Member?> getSelfMember(
  GetSelfMemberRef ref,
  Snowflake guildId,
) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();

  if (authOutput is AuthUser) {
    return await authOutput.client.guilds[guildId].members
        .get(authOutput.client.user.id);
  }
}

@riverpod
Future<List<Role>?> getGuildRoles(
    GetGuildRolesRef ref, Snowflake guildId) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();

  if (authOutput is AuthUser) {
    return await authOutput.client.guilds[guildId].roles.list();
  }
}

@riverpod
Future<Role> getRole(GetRoleRef ref, Guild guild, Snowflake roleId) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();

  if (authOutput is AuthUser) {
    return await authOutput.client.guilds[guild.id].roles.get(roleId);
  } else {
    throw Exception('No auth user');
  }
}
