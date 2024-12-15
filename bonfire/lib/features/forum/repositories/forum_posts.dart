import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forum_posts.g.dart';

/// Fetches a forum channel from the [channelId].
@Riverpod(keepAlive: true)
class ForumPosts extends _$ForumPosts {
  @override
  Future<ThreadList?> build(Snowflake channelId) async {
    var auth = ref.watch(authProvider.notifier).getAuth();

    if (auth is AuthUser) {
      Channel channel = await auth.client.channels.get(channelId);
      if (channel is ForumChannel) {
        print("is a forum channel");
        Guild guild = await auth.client.guilds.get(channel.guildId);
        // ThreadList threads = []; // await guild.listActiveThreads();

        // print('got active threads');
        // print(threads);

        // return channel.listPublicArchivedThreads()
      }
    }

    return null;
  }
}
