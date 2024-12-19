import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/utils/endpoint_paginator.dart';

/// Extensions on [AuditLogManager].
extension AuditLogManagerExtensions on AuditLogManager {
  /// Same as [list], but has no limit on the number of entries returned.
  ///
  /// {@macro paginated_endpoint_streaming_parameters}
  ///
  /// {@macro paginated_endpoint_order_parameters}
  Stream<AuditLogEntry> stream({
    Snowflake? userId,
    AuditLogEvent? type,
    Snowflake? before,
    Snowflake? after,
    int? pageSize,
    StreamOrder? order,
  }) =>
      streamPaginatedEndpoint(
        ({after, before, limit}) => list(
            userId: userId,
            type: type,
            after: after,
            before: before,
            limit: limit),
        extractId: (entry) => entry.id,
        before: before,
        after: after,
        pageSize: pageSize,
        order: order,
      );
}
