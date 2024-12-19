import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/utils/endpoint_paginator.dart';

/// Extensions on [UserManager]s.
extension UserManagerExtensions on UserManager {
  /// Same as [listCurrentUserGuilds], but has no limit on the number of guilds returned.
  ///
  /// {@macro paginated_endpoint_streaming_parameters}
  ///
  /// {@macro paginated_endpoint_order_parameters}
  Stream<PartialGuild> streamCurrentUserGuilds({
    Snowflake? after,
    Snowflake? before,
    bool? withCounts,
    int? pageSize,
    StreamOrder? order,
  }) =>
      streamPaginatedEndpoint(
        ({after, before, limit}) => listCurrentUserGuilds(
            after: after, before: before, limit: limit, withCounts: withCounts),
        extractId: (guild) => guild.id,
        before: before,
        after: after,
        pageSize: pageSize,
        order: order,
      );
}
