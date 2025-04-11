import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/features/forum/controllers/forum.dart';
import 'package:bonfire/features/messaging/controllers/message.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forum_posts.g.dart';

/// Fetches a forum channel from the [channelId].
@Riverpod(keepAlive: true)
class ForumPosts extends _$ForumPosts {
  int _currentOffset = 0;
  bool _hasMore = true;
  AuthUser? authUser;

  @override
  Future<List<ThreadList?>> build(Snowflake channelId) async {
    var auth = ref.watch(authProvider);
    if (auth is AuthUser) authUser = auth;

    _currentOffset = 0;
    _hasMore = true;
    return [await _fetchThreads(channelId)];
  }

  Future<ThreadList?> _fetchThreads(Snowflake channelId) async {
    if (authUser is AuthUser) {
      Channel channel = await authUser!.client.channels.get(channelId);
      if (channel is ForumChannel) {
        ThreadList? threadData = await channel.manager.searchThreads(
          channel.id,
          25,
          offset: _currentOffset,
        );

        if (threadData != null) {
          _hasMore = threadData.threads.length == 25;

          for (var element in threadData.threads) {
            ref
                .read(threadChannelProvider(element.id).notifier)
                .setThreadChannel(element);
          }

          int idx = 0;
          for (var message in threadData.firstMessages) {
            ref
                .read(messageControllerProvider(message.id).notifier)
                .setMessage(message);

            var thread = threadData.threads[idx];

            ref
                .read(firstMessageProvider(thread.id).notifier)
                .setFirstMessage(message);

            idx++;
          }

          return threadData;
        }
      }
    }

    return null;
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;

    _currentOffset += 25;
    final newThreads = await _fetchThreads(channelId);

    if (newThreads != null) {
      state = AsyncData([...state.value ?? [], newThreads]);
    }
  }

  bool get hasMore => _hasMore;
}
