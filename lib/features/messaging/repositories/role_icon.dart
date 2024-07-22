import 'dart:typed_data';

import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/shared/utils/role_color.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'role_icon.g.dart';

@riverpod
Future<Uint8List?> roleIcon(
    RoleIconRef ref, Snowflake guildId, Snowflake authorId) async {
  var member = ref.watch(getMemberProvider(guildId, authorId)).valueOrNull;
  List<Role>? roles = ref.watch(getGuildRolesProvider(guildId)).valueOrNull;
  if (member == null || roles == null) return null;

  String? url = getRoleIconUrl(member, roles);
  if (url == null) return null;

  var bytes = (await http.get(Uri.parse(url))).bodyBytes;

  return bytes;
}

@riverpod
Future<Color> roleColor(
    RoleColorRef ref, Snowflake guildId, Snowflake authorId) async {
  var member = ref.watch(getMemberProvider(guildId, authorId)).valueOrNull;
  List<Role>? roles = ref.watch(getGuildRolesProvider(guildId)).valueOrNull;
  if (member == null || roles == null) return Colors.white;

  return getRoleColor(member, roles);
}
