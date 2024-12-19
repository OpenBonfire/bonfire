import 'dart:convert';

import 'package:firebridge/src/builders/role.dart';
import 'package:firebridge/src/errors.dart';
import 'package:firebridge/src/http/managers/manager.dart';
import 'package:firebridge/src/http/request.dart';
import 'package:firebridge/src/http/route.dart';
import 'package:firebridge/src/models/discord_color.dart';
import 'package:firebridge/src/models/permissions.dart';
import 'package:firebridge/src/models/role.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/utils/cache_helpers.dart';
import 'package:firebridge/src/utils/parsing_helpers.dart';

/// A manager for [Role]s.
class RoleManager extends Manager<Role> {
  /// The ID of the guild this manager is for.
  final Snowflake guildId;

  /// Create a new [RoleManager].
  RoleManager(super.config, super.client, {required this.guildId})
      : super(identifier: '$guildId.roles');

  @override
  PartialRole operator [](Snowflake id) =>
      PartialRole(id: id, json: {}, manager: this);

  @override
  Role parse(Map<String, Object?> raw) {
    return Role(
      id: Snowflake.parse(raw['id']!),
      json: raw,
      manager: this,
      name: raw['name'] as String,
      color: DiscordColor(raw['color'] as int),
      isHoisted: raw['hoist'] as bool,
      iconHash: raw['icon'] as String?,
      unicodeEmoji: raw['unicode_emoji'] as String?,
      position: raw['position'] as int,
      permissions: Permissions(int.parse(raw['permissions'] as String)),
      isMentionable: raw['mentionable'] as bool,
      tags: maybeParse(raw['tags'], parseRoleTags),
      flags: RoleFlags(raw['flags'] as int),
    );
  }

  /// Parse [RoleTags] from [raw].
  RoleTags parseRoleTags(Map<String, Object?> raw) {
    return RoleTags(
      botId: maybeParse(raw['bot_id'], Snowflake.parse),
      integrationId: maybeParse(raw['integration_id'], Snowflake.parse),
      isPremiumSubscriber: raw.containsKey('premium_subscriber'),
      subscriptionListingId:
          maybeParse(raw['subscription_listing_id'], Snowflake.parse),
      isAvailableForPurchase: raw.containsKey('available_for_purchase'),
      isLinkedRole: raw.containsKey('guild_connections'),
    );
  }

  /// List the roles in this guild.
  Future<List<Role>> list() async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..roles();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final roles = parseMany(response.jsonBody as List, parse);

    roles.forEach(client.updateCacheWith);
    return roles;
  }

  @override
  Future<Role> fetch(Snowflake id) async {
    // There isn't an endpoint to fetch a single role. Re-fetch all the roles to ensure they are up to date,
    // and return the matching role.
    final roles = await list();

    return roles.firstWhere(
      (role) => role.id == id,
      orElse: () => throw RoleNotFoundException(guildId, id),
    );
  }

  @override
  Future<Role> create(RoleBuilder builder, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..roles();
    final request = BasicRequest(route,
        method: 'POST',
        auditLogReason: auditLogReason,
        body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final role = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(role);
    return role;
  }

  @override
  Future<Role> update(Snowflake id, RoleUpdateBuilder builder,
      {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..roles(id: id.toString());
    final request = BasicRequest(route,
        method: 'PATCH',
        auditLogReason: auditLogReason,
        body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    final role = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(role);
    return role;
  }

  @override
  Future<void> delete(Snowflake id, {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..roles(id: id.toString());
    final request =
        BasicRequest(route, method: 'DELETE', auditLogReason: auditLogReason);

    await client.httpHandler.executeSafe(request);
    cache.remove(id);
  }

  /// Update the positions of the roles in this guild.
  Future<List<Role>> updatePositions(Map<Snowflake, int> positions,
      {String? auditLogReason}) async {
    final route = HttpRoute()
      ..guilds(id: guildId.toString())
      ..roles();
    final request = BasicRequest(
      route,
      method: 'PATCH',
      auditLogReason: auditLogReason,
      body: jsonEncode(positions.entries
          .map((e) => {'id': e.key.toString(), 'position': e.value})
          .toList()),
    );

    final response = await client.httpHandler.executeSafe(request);
    final roles = parseMany(response.jsonBody as List, parse);

    roles.forEach(client.updateCacheWith);
    return roles;
  }
}
