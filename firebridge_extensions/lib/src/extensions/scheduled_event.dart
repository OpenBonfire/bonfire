import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/extensions/managers/scheduled_event_manager.dart';
import 'package:firebridge_extensions/src/utils/endpoint_paginator.dart';

/// Extensions on [PartialScheduledEvent].
extension PartialScheduledEventExtensions on PartialScheduledEvent {
  /// Same as [listUsers], but has no limit on the number of users returned.
  ///
  /// {@macro paginated_endpoint_streaming_parameters}
  ///
  /// {@macro paginated_endpoint_order_parameters}
  Stream<ScheduledEventUser> streamUsers({
    bool? withMembers,
    Snowflake? before,
    Snowflake? after,
    int? pageSize,
    StreamOrder? order,
  }) =>
      manager.streamEventUsers(
        id,
        after: after,
        before: before,
        order: order,
        pageSize: pageSize,
        withMembers: withMembers,
      );
}
