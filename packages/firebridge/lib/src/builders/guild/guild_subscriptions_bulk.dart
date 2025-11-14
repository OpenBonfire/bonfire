import 'package:firebridge/src/builders/builder.dart';
import 'package:firebridge/src/models/gateway/events/guild.dart';
import 'package:firebridge/src/models/guild/guild_subscription.dart';

class GuildSubscriptionsBulkBuilder
    extends CreateBuilder<GuildSubscriptionsBulkEvent> {
  List<GuildSubscription>? subscriptions;

  @override
  Map<String, Object?> build() {
    final _subscriptions = <String, Map<String, dynamic>>{};

    subscriptions?.forEach((subscription) {
      final guildKey = subscription.guildId.value.toString();
      final channels = <String, dynamic>{};

      subscription.channels.forEach((channel) {
        final channelKey = channel.channelId.value.toString();
        // Store a list of ranges for each channel
        channels[channelKey] = channel.memberRange
            .map((range) => [
                  range.lowerMemberBound,
                  range.upperMemberBound,
                ])
            .toList();
      });

      _subscriptions[guildKey] = {
        if (subscription.typing != null) "typing": subscription.typing,
        if (subscription.threads != null) "threads": subscription.threads,
        if (subscription.activities != null)
          "activities": subscription.activities,
        if (subscription.memberUpdates != null)
          "member_updates": subscription.memberUpdates,
        if (subscription.members != null) "members": subscription.members,
        if (subscription.threadMemberLists != null)
          "thread_member_lists": subscription.threadMemberLists,
        "channels": channels,
      };
    });

    return {"subscriptions": _subscriptions};
  }
}
