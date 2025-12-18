import 'dart:typed_data';

import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/shared/utils/role_color.dart';
import 'package:firebridge/firebridge.dart' hide CacheManager;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'role_icon.g.dart';

// role icon cache using flutter_cache_manager
var roleIconCache = CacheManager(
  Config('role_icon_cache', maxNrOfCacheObjects: 1000),
);

@Riverpod(keepAlive: true)
Future<Uint8List?> roleIcon(
  Ref ref,
  Snowflake guildId,
  Snowflake authorId,
) async {
  var member = ref.watch(getMemberProvider(guildId, authorId)).value;
  List<Role>? roles = ref.watch(getGuildRolesProvider(guildId)).value;
  if (member == null || roles == null) return null;

  String? url = getRoleIconUrl(member, roles);

  if (url == null) return null;

  var fromCache = await roleIconCache.getFileFromCache(url);
  if (fromCache != null) {
    return fromCache.file.readAsBytes();
  }

  var bytes = (await http.get(Uri.parse(url))).bodyBytes;
  await roleIconCache.putFile(url, bytes);

  return bytes;
}

@riverpod
Future<Color> roleColor(Ref ref, Snowflake guildId, Snowflake authorId) async {
  var member = ref.watch(getMemberProvider(guildId, authorId)).value;
  List<Role>? roles = ref.watch(getGuildRolesProvider(guildId)).value;
  if (member == null || roles == null) return Colors.white;

  return getRoleColor(member, roles);
}
