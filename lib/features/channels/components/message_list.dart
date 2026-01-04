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
    return CustomScrollView(
      reverse: true,
      slivers: [
        SliverList.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return Text(message.content);
          },
        ),
      ],
    );
  }
}
