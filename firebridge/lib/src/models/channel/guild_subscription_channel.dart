import 'package:firebridge/src/models/guild/guild_member_range.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

/// Represents a subscription channel for a guild
class GuildSubscriptionChannel with ToStringHelper {
  final Snowflake channelId;
  final GuildMemberRange memberRange;

  GuildSubscriptionChannel({
    required this.channelId,
    required this.memberRange,
  });
}
