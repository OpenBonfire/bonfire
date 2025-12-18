import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member.g.dart';

@Riverpod(keepAlive: true)
Future<Member?> getMember(
  Ref ref,
  Snowflake guildId,
  Snowflake memberId,
) async {
  var authOutput = ref.watch(clientControllerProvider);

  if (authOutput is AuthUser) {
    // return await authOutput.client.guilds[guildId].members.get(memberId);
  }

  return null;
}

@Riverpod(keepAlive: true)
Future<Member?> getSelfMember(Ref ref, Snowflake guildId) async {
  var authOutput = ref.watch(clientControllerProvider);

  if (authOutput is AuthUser) {
    // return await authOutput.client.guilds[guildId].members.get(
    //   authOutput.client.user.id,
    // );
  }
  return null;
}

@Riverpod(keepAlive: true)
Future<List<Role>?> getGuildRoles(Ref ref, Snowflake guildId) async {
  var authOutput = ref.watch(clientControllerProvider);

  // if (authOutput is AuthUser) {
  //   return await authOutput.client.guilds[guildId].roles.list();
  // }
  return null;
}

@riverpod
Future<Role?> getRole(Ref ref, Snowflake guildId, Snowflake roleId) async {
  var authOutput = ref.watch(clientControllerProvider);

  // if (authOutput is AuthUser) {
  //   return await authOutput.client.gui.roles.get(roleId);
  // } else {
  //   throw Exception('No auth user');
  // }
  return null;
}
