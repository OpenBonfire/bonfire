import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/forum/views/forum.dart';
import 'package:bonfire/features/messaging/views/components/message_list.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageView extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  const MessageView(
      {super.key, required this.guildId, required this.channelId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageView> {
  @override
  Widget build(BuildContext context) {
    Channel? channel =
        ref.watch(channelControllerProvider(widget.channelId)).valueOrNull;

    if (channel is TextChannel) {
      return MessageList(guildId: widget.guildId, channelId: widget.channelId);
    } else if (channel is ForumChannel) {
      return ForumView(guildId: widget.guildId, channelId: widget.channelId);
    }

    return Center(
        child: Text(
      'Channel type not yet supported!',
      style: GoogleFonts.publicSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    ));
  }
}
