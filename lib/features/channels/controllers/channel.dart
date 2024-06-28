import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channel.g.dart';

/// Fetches the current channel from the [channelid].
@riverpod
class ChannelController extends _$ChannelController {
  Channel? channel;

  @override
  Future<Channel?> build(String channelId) async {
    var auth = ref.watch(authProvider.notifier).getAuth();

    Snowflake channel = Snowflake(int.parse(channelId));

    if (auth is AuthUser) {
      return await auth.client.channels.get(channel);
    }

    return null;
  }
}
