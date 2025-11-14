import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/utils/endpoint_paginator.dart';

/// Extensions on [ChannelManager]s.
extension ChannelManagerExtensions on ChannelManager {
  /// Same as [listThreadMembers], but has no limit on the number of members returned.
  ///
  /// {@macro paginated_endpoint_streaming_parameters}
  Stream<ThreadMember> streamThreadMembers(
    Snowflake id, {
    bool? withMembers,
    Snowflake? after,
    Snowflake? before,
    int? pageSize,
  }) =>
      streamPaginatedEndpoint(
        ({after, before, limit}) => listThreadMembers(id,
            withMembers: withMembers, after: after, limit: limit),
        extractId: (member) => member.userId,
        before: before,
        after: after,
        pageSize: pageSize,
        order: StreamOrder.oldestFirst,
      );
}
