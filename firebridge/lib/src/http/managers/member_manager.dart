import 'dart:convert';

import 'package:firebridge/src/builders/guild/member.dart';
import 'package:firebridge/src/errors.dart';
import 'package:firebridge/src/gateway/gateway.dart';
import 'package:firebridge/src/http/managers/manager.dart';
import 'package:firebridge/src/http/request.dart';
import 'package:firebridge/src/http/route.dart';
import 'package:firebridge/src/models/guild/member.dart';
import 'package:firebridge/src/models/permissions.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/utils/cache_helpers.dart';
import 'package:firebridge/src/utils/parsing_helpers.dart';

/// A manager for [Member]s.
class MemberManager extends Manager<Member> {
  /// The ID of the [Guild] this manager is for.
  final Snowflake guildId;

  MemberManager(super.config, super.client, {required this.guildId})
      : super(identifier: '$guildId.members');

  @override
  PartialMember operator [](Snowflake id) =>
      PartialMember(id: id, json: {}, manager: this);

  @override
  Member parse(Map<String, Object?> raw,
      {Snowflake? userId, Gateway? gateway}) {
    return Member(
      id: maybeParse(
              (raw['user'] as Map<String, Object?>?)?['id'], Snowflake.parse) ??
          userId ??
          Snowflake.zero,
      json: raw,
      manager: this,
      user: maybeParse(raw['user'], client.users.parse),
      nick: raw['nick'] as String?,
      avatarHash: raw['avatar'] as String?,
      roleIds: parseMany(raw['roles'] as List, Snowflake.parse),
      joinedAt: DateTime.parse(raw['joined_at'] as String),
      premiumSince: maybeParse(raw['premium_since'], DateTime.parse),
      isDeaf: raw['deaf'] as bool?,
      isMute: raw['mute'] as bool?,
      flags: MemberFlags(raw['flags'] as int),
      isPending: raw['pending'] as bool? ?? false,
      permissions: maybeParse(
          raw['permissions'], (String raw) => Permissions(int.parse(raw))),
      communicationDisabledUntil:
          maybeParse(raw['communication_disabled_until'], DateTime.parse),
      initialPresence:
          gateway?.parsePresenceUpdate(raw['presence'] as Map<String, dynamic>),
    );
  }

  @override
  Future<Member> fetch(Snowflake id) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final member = parse(response.jsonBody as Map<String, Object?>, userId: id);

    client.updateCacheWith(member);
    return member;
  }

  /// List the members in the guild.
  Future<List<Member>> list({int? limit, Snowflake? after}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members();
    final request = BasicRequest(route, queryParameters: {
      if (limit != null) 'limit': limit.toString(),
      if (after != null) 'after': after.toString(),
    });

    final response = await client.httpHandler.executeSafe(request);
    final members = parseMany(response.jsonBody as List, parse);

    members.forEach(client.updateCacheWith);
    return members;
  }

  @override
  Future<Member> create(MemberBuilder builder) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: builder.userId.toString());
    final request =
        BasicRequest(route, method: 'PUT', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    if (response.statusCode == 204) {
      throw MemberAlreadyExistsException(guildId, builder.userId);
    }

    final member = parse(response.jsonBody as Map<String, Object?>,
        userId: builder.userId);

    client.updateCacheWith(member);
    return member;
  }

  @override
  Future<Member> update(Snowflake id, MemberUpdateBuilder builder,
      {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: id.toString());
    final request = BasicRequest(route,
        method: 'PATCH',
        auditLogReason: auditLogReason,
        body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final member = parse(response.jsonBody as Map<String, Object?>, userId: id);

    client.updateCacheWith(member);
    return member;
  }

  /// Kick a member.
  @override
  Future<void> delete(Snowflake id, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: id.toString());
    final request =
        BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }

  /// Search for members whose username begins with [query].
  Future<List<Member>> search(String query, {int? limit}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members()
      ..search();
    final request = BasicRequest(route, queryParameters: {
      'query': query,
      if (limit != null) 'limit': limit.toString()
    });

    final response = await client.httpHandler.executeSafe(request);
    final members = parseMany(response.jsonBody as List, parse);

    members.forEach(client.updateCacheWith);
    return members;
  }

  /// Update the current member in the guild.
  Future<Member> updateCurrentMember(CurrentMemberUpdateBuilder builder,
      {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: '@me');
    final request = BasicRequest(route,
        method: 'PATCH',
        body: jsonEncode(builder.build()),
        auditLogReason: auditLogReason);

    final response = await client.httpHandler.executeSafe(request);
    final member = parse(response.jsonBody as Map<String, Object?>,
        userId: client.user.id);

    client.updateCacheWith(member);
    return member;
  }

  /// Add a role to a member in the guild.
  Future<void> addRole(Snowflake id, Snowflake roleId,
      {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: id.toString())
      ..roles(id: roleId.toString());
    final request =
        BasicRequest(route, method: 'PUT', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
  }

  /// Remove a role from a member in the guild.
  Future<void> removeRole(Snowflake id, Snowflake roleId,
      {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..members(id: id.toString())
      ..roles(id: roleId.toString());
    final request =
        BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
  }
}
