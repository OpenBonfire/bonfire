import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/utils/endpoint_paginator.dart';

/// Extensions on [MessageManager]s.
extension MessageManagerExtensions on MessageManager {
  /// Same as [fetchMany], but has no limit on the number of messages returned.
  ///
  /// {@template paginated_endpoint_streaming_parameters}
  /// If [after] is set, only entities whose ID is after it will be returned.
  /// If [before] is set, only entities whose ID is before it will be returned.
  ///
  /// [pageSize] can be set to control the `limit` parameter of the underlying
  /// requests to the paginated endpoint. Most users will want to leave this
  /// unset and default to the maximum page size.
  /// {@endtemplate}
  ///
  /// {@template paginated_endpoint_order_parameters}
  /// [order] can be set to change the order in which entities are emitted on
  /// the returned stream. Entities will be emitted oldest first if it is not
  /// set, unless only [before] is provided, in which case entities will be
  /// emitted most recent first.
  /// {@endtemplate}
  Stream<Message> stream({
    Snowflake? before,
    Snowflake? after,
    int? pageSize,
    StreamOrder? order,
  }) =>
      streamPaginatedEndpoint(
        fetchMany,
        extractId: (message) => message.id,
        before: before,
        after: after,
        pageSize: pageSize,
        order: order,
      );

  /// Same as [fetchReactions], but has no limit on the number of reactions returned.
  ///
  /// {@macro paginated_endpoint_streaming_parameters}
  Stream<User> streamReactions(
    Snowflake id,
    ReactionBuilder emoji, {
    Snowflake? after,
    Snowflake? before,
    int? pageSize,
  }) =>
      streamPaginatedEndpoint(
        ({before, after, limit}) =>
            fetchReactions(id, emoji, after: after, limit: limit),
        extractId: (user) => user.id,
        before: before,
        after: after,
        pageSize: pageSize,
        order: StreamOrder.oldestFirst,
      );
}
