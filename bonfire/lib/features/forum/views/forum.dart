import 'package:bonfire/features/forum/repositories/forum_posts.dart';
import 'package:bonfire/features/forum/repositories/forums.dart';
import 'package:bonfire/features/forum/components/card/card.dart';
import 'package:bonfire/features/messaging/components/channel_header.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForumView extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;

  const ForumView({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForumViewState();
}

class _ForumViewState extends ConsumerState<ForumView> {
  final ScrollController _scrollController = ScrollController();
  List<Channel> threads = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final channel = ref.read(forumsProvider(widget.channelId)).valueOrNull;
      if (channel != null) {
        final forumPosts = ref.read(forumPostsProvider(channel.id).notifier);
        if (forumPosts.hasMore) {
          forumPosts.loadMore();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final channel = ref.watch(forumsProvider(widget.channelId)).valueOrNull;

    if (channel == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final postsAsync = ref.watch(forumPostsProvider(channel.id));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: postsAsync.when(
          data: (threadLists) {
            // Combine all threads from the list of ThreadLists
            threads = threadLists.expand((threadList) {
              return threadList?.threads ?? [] as List<Channel>;
            }).toList();

            return Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  itemCount: threads.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ThreadCard(
                        threadId: threads[index].id,
                        channelId: channel.id,
                      ),
                    );
                  },
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 60,
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                ),
                ChannelHeader(
                  channelId: channel.id,
                ),
              ],
            );
          },
          loading: () => threads.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: threads.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ThreadCard(
                        channelId: threads[index].id,
                        threadId: threads[index].id,
                      ),
                    );
                  },
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                ),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
