import 'package:bonfire/features/forum/repositories/forum_posts.dart';
import 'package:bonfire/features/forum/repositories/forums.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForumView extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  const ForumView({super.key, required this.guildId, required this.channelId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForumViewState();
}

class _ForumViewState extends ConsumerState<ForumView> {
  @override
  Widget build(BuildContext context) {
    ForumChannel? channel =
        ref.watch(forumsProvider(widget.channelId)).valueOrNull;
    if (channel != null) {
      var posts = ref.watch(forumPostsProvider(channel.id));
      posts.when(
        data: (data) {
          print("got data");
          print(data);
        },
        loading: () {
          print("loading");
        },
        error: (error, stack) {
          print("error");
          print(error);
          print(stack);
        },
      );
      print("not null, posts!");
    }
    return ListView.builder(itemBuilder: (context, index) {
      return ListTile(
        title: Text('Forum Post $index'),
        subtitle: Text('This is the subtitle for post $index'),
        onTap: () {},
      );
    });
  }
}
