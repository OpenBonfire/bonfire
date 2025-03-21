import 'package:bonfire/features/authenticator/data/repositories/auth.dart';
import 'package:bonfire/features/authenticator/data/repositories/discord_auth.dart';
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

  return null;
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
  return null;
}

@Riverpod(keepAlive: true)
Future<List<Role>?> getGuildRoles(
    GetGuildRolesRef ref, Snowflake guildId) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();

  if (authOutput is AuthUser) {
    return await authOutput.client.guilds[guildId].roles.list();
  }
  return null;
}

@riverpod
Future<Role> getRole(
    GetRoleRef ref, Snowflake guildid, Snowflake roleId) async {
  var authOutput = ref.watch(authProvider.notifier).getAuth();

  if (authOutput is AuthUser) {
    return await authOutput.client.guilds[guildid].roles.get(roleId);
  } else {
    throw Exception('No auth user');
  }
}
