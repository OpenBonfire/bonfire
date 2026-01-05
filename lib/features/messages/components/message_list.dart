import 'package:bonfire/features/messages/components/box/box.dart';
import 'package:bonfire/features/messages/providers/messages.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelMessageList extends ConsumerStatefulWidget {
  final Snowflake channelId;
  const ChannelMessageList({super.key, required this.channelId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChannelMessageListState();
}

class _ChannelMessageListState extends ConsumerState<ChannelMessageList> {
  @override
  Widget build(BuildContext context) {
    // TODO: use bidirectional scroll view
    final messages = ref.watch(channelMessagesProvider(widget.channelId)).value;
    if (messages == null) {
      return Center(child: CircularProgressIndicator.adaptive());
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 1500) {
          ref
              .read(channelMessagesProvider(widget.channelId).notifier)
              .loadMore();
        }
        return false;
      },
      child: CustomScrollView(
        reverse: true,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 20.0),
            sliver: SliverList.separated(
              itemCount: messages.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                bool showAuthor = true;
                if (index + 1 < messages.length) {
                  Message currentMessage = messages[index];
                  Message lastMessage = messages[index + 1];

                  showAuthor =
                      lastMessage.author.id != currentMessage.author.id;

                  if (currentMessage.timestamp
                          .difference(lastMessage.timestamp)
                          .inMinutes >
                      5) {
                    showAuthor = true;
                  }
                  if (currentMessage.referencedMessage != null) {
                    showAuthor = true;
                  }
                } else {
                  showAuthor = true;
                }

                final message = messages[index];

                return MessageBox(message: message, showAuthor: showAuthor);
              },
            ),
          ),
        ],
      ),
    );
  }
}
