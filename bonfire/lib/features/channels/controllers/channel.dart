import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channel.g.dart';

/// Fetches the current channel from the [channelid].
@Riverpod(keepAlive: true)
class ChannelController extends _$ChannelController {
  Channel? channel;

  // TODO: We don't need to cache this, we should get it onReady then on the subsequent events

  @override
  Channel? build(Snowflake channelId) {
    if (channelId == Snowflake.zero) {
      return null;
    }

    return null;
  }

  void setChannel(Channel channel) {
    state = channel;
  }
}
