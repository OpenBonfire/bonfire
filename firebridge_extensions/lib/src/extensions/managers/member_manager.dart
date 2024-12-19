import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/utils/endpoint_paginator.dart';

/// Extensions on [MemberManager]s.
extension MemberManagerExtensions on MemberManager {
  /// Same as [list], but has no limit on the number of members returned.
  ///
  /// {@macro paginated_endpoint_streaming_parameters}
  Stream<Member> stream({
    Snowflake? after,
    Snowflake? before,
    int? pageSize,
  }) =>
      streamPaginatedEndpoint(
        ({after, before, limit}) => list(after: after, limit: limit),
        extractId: (member) => member.id,
        before: before,
        after: after,
        pageSize: pageSize,
        order: StreamOrder.oldestFirst,
      );
}
