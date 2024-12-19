import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/utils/endpoint_paginator.dart';

/// Extensions on [ScheduledEventManager]s.
extension ScheduledEventManagerExtensions on ScheduledEventManager {
  /// Same as [listEventUsers], but has no limit on the number of users returned.
  ///
  /// {@macro paginated_endpoint_streaming_parameters}
  ///
  /// {@macro paginated_endpoint_order_parameters}
  Stream<ScheduledEventUser> streamEventUsers(
    Snowflake id, {
    bool? withMembers,
    Snowflake? before,
    Snowflake? after,
    int? pageSize,
    StreamOrder? order,
  }) =>
      streamPaginatedEndpoint(
        ({after, before, limit}) => listEventUsers(id,
            after: after,
            before: before,
            limit: limit,
            withMembers: withMembers),
        extractId: (user) => user.user.id,
        before: before,
        after: after,
        pageSize: pageSize,
        order: order,
      );
}
