import 'package:bonfire/features/messages/components/bidirectional_scroll_view.dart';
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
    return BidirectionalScrollView();
  }
}
