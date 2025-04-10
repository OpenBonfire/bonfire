import 'package:firebridge/src/http/managers/channel_manager.dart';
import 'package:firebridge/src/models/channel/channel.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/models/webhook.dart';
import 'package:firebridge/src/utils/to_string_helper/to_string_helper.dart';

/// {@template followed_channel}
/// Information about a channel which has been followed.
/// {@endtemplate}
class FollowedChannel with ToStringHelper {
  /// The manager for this [FollowedChannel].
  final ChannelManager manager;

  /// The ID of the channel that has been followed.
  final Snowflake channelId;

  /// The ID of the webhook created in the subscriber channel.
  final Snowflake webhookId;

  /// {@macro followed_channel}
  /// @nodoc
  FollowedChannel({required this.manager, required this.channelId, required this.webhookId});

  /// The followed channel.
  PartialChannel get channel => manager.client.channels[channelId];

  /// The webhook created in the subscriber channel.
  PartialWebhook get webhook => manager.client.webhooks[webhookId];
}
