import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/utils/endpoint_paginator.dart';

/// Extensions on [EntitlementManager]s.
extension EntitlementManagerExtensions on EntitlementManager {
  /// Same as [list], but has no limit on the number of entitlements returned.
  ///
  /// {@macro paginated_endpoint_streaming_parameters}
  ///
  /// {@macro paginated_endpoint_order_parameters}
  Stream<Entitlement> stream({
    Snowflake? userId,
    List<Snowflake>? skuIds,
    Snowflake? before,
    Snowflake? after,
    int? pageSize,
    Snowflake? guildId,
    bool? excludeEnded,
    StreamOrder? order,
  }) =>
      streamPaginatedEndpoint(
        ({after, before, limit}) => list(
          after: after,
          before: before,
          excludeEnded: excludeEnded,
          guildId: guildId,
          limit: limit,
          skuIds: skuIds,
          userId: userId,
        ),
        extractId: (entitlement) => entitlement.id,
        before: before,
        after: after,
        pageSize: pageSize,
        order: order,
      );
}
