import 'package:bonfire/features/channels/components/message_list.dart';
import 'package:bonfire/features/messages/components/bidirectional_scroll_view.dart';
import 'package:bonfire/features/messages/components/message_screen.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelMessageScreen extends ConsumerStatefulWidget {
  final Snowflake channelId;
  const ChannelMessageScreen({super.key, required this.channelId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChannelMessageScreenState();
}

class _ChannelMessageScreenState extends ConsumerState<ChannelMessageScreen> {
  @override
  Widget build(BuildContext context) {
    return MessageScreen(
      title: Text("id = ${widget.channelId}"),
      child: ChannelMessageList(channelId: widget.channelId),
    );
  }
}
