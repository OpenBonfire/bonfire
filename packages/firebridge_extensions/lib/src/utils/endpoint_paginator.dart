import 'package:firebridge/firebridge.dart';

/// Controls the order in which entities from paginated endpoints are streamed.
enum StreamOrder {
  /// Emit the entities in order of most recent to oldest.
  mostRecentFirst,

  /// Emit the entities on order of oldest to most recent.
  oldestFirst,
}

/// Wrap the paginated API call [fetchPage] into a stream.
///
/// Although this function supports bi-directional emitting of events using the
/// [order] parameter, it can be used for API endpoints that only support
/// pagination in one direction by hard-coding the [order] parameter to match
/// the API order.
Stream<T> streamPaginatedEndpoint<T>(
  Future<List<T>> Function({Snowflake? before, Snowflake? after, int? limit})
      fetchPage, {
  required Snowflake Function(T) extractId,
  required Snowflake? before,
  required Snowflake? after,
  required int? pageSize,
  required StreamOrder? order,
}) async* {
  // Both after and before:    oldest first
  // Only after:               oldest first
  // Only before:              most recent first
  // Neither after nor before: oldest first
  order ??= before != null && after == null
      ? StreamOrder.mostRecentFirst
      : StreamOrder.oldestFirst;
  before ??= Snowflake.now();
  after ??= Snowflake.zero;

  var nextPageBefore = before;
  var nextPageAfter = after;

  while (true) {
    // We choose the order of the pages by passing either before or after
    // depending on the stream order.
    final page = await switch (order) {
      StreamOrder.mostRecentFirst =>
        fetchPage(limit: pageSize, before: nextPageBefore),
      StreamOrder.oldestFirst =>
        fetchPage(limit: pageSize, after: nextPageAfter),
    };

    if (page.isEmpty) {
      break;
    }

    final pageWithIds = [
      for (final entity in page) (id: extractId(entity), entity: entity),
    ];

    // Some endpoints return entities in the same order regardless of if before
    // or after were passed. Sort the entities according to our stream order to
    // fix this.
    // This could probably be made more efficient by assuming that endpoints
    // always return entities in either ascending or descending order, but for
    // now it's a good sanity check.
    if (order == StreamOrder.oldestFirst) {
      // Oldest first: ascending order.
      pageWithIds.sort((a, b) => a.id.compareTo(b.id));
    } else {
      // Most recent first: descending order.
      pageWithIds.sort((a, b) => -a.id.compareTo(b.id));
    }

    for (final (:id, :entity) in pageWithIds) {
      if (id.isBefore(before) && id.isAfter(after)) {
        yield entity;
      }
    }

    if (order == StreamOrder.oldestFirst) {
      nextPageAfter = pageWithIds.last.id;
    } else {
      nextPageBefore = pageWithIds.last.id;
    }

    // The extra == check isn't strictly necessary, but it saves us an API call
    // in the common case of setting `before` or `after` to an entity's ID.
    if (nextPageAfter.isAfter(before) || nextPageAfter == before) {
      break;
    }
    if (nextPageBefore.isBefore(after) || nextPageBefore == after) {
      break;
    }
  }
}
