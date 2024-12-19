import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/utils/endpoint_paginator.dart';

/// Extensions on [GuildManager]s.
extension GuildManagerExtensions on GuildManager {
  /// Same as [listBans], but has no limit on the number of bans returned.
  ///
  /// {@macro paginated_endpoint_streaming_parameters}
  Stream<Ban> streamBans(
    Snowflake id, {
    Snowflake? after,
    Snowflake? before,
    int? pageSize,
  }) =>
      streamPaginatedEndpoint(
        ({after, before, limit}) =>
            listBans(id, after: after, before: before, limit: limit),
        extractId: (ban) => ban.user.id,
        before: before,
        after: after,
        pageSize: pageSize,
        order: StreamOrder.oldestFirst,
      );
}
