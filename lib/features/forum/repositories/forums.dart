import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forums.g.dart';

/// Fetches a forum channel from the [channelId].
@Riverpod(keepAlive: true)
class Forums extends _$Forums {
  @override
  Future<ForumChannel> build(Snowflake channelId) async {
    final client = ref.watch(clientControllerProvider)!;

    Channel channel = await client.channels.fetch(channelId);

    return channel as ForumChannel;
  }
}
