import 'package:firebridge/src/models/channel/guild_subscription_channel.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/utils/to_string_helper/to_string_helper.dart';

class GuildSubscription with ToStringHelper {
  final bool? typing;
  final bool? threads;
  final bool? activities;
  final bool? memberUpdates;
  final List<Snowflake>? members;
  final List<Snowflake>? threadMemberLists;
  final List<GuildSubscriptionChannel> channels;
  final Snowflake guildId;

  GuildSubscription({
    this.typing,
    this.threads,
    this.activities,
    this.members,
    this.memberUpdates,
    this.threadMemberLists,
    required this.channels,
    required this.guildId,
  });
}
