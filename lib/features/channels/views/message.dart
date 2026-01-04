import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:bonfire/features/messages/components/bar/bar.dart';
import 'package:bonfire/features/messages/components/message_list.dart';
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
    final channel =
        ref.watch(channelProvider(widget.channelId)) as GuildChannel?;
    return MessageScreen(
      title: Text(channel?.name ?? "No name idk"),
      child: Column(
        children: [
          Expanded(child: ChannelMessageList(channelId: widget.channelId)),
          ChannelMessageBar(channelId: widget.channelId),
        ],
      ),
    );
  }
}
