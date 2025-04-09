import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/channel_repo.dart';
import 'package:bonfire/features/forum/views/forum.dart';
import 'package:bonfire/features/messaging/components/message_list.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageView extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  final Snowflake? threadId;
  const MessageView({
    super.key,
    required this.guildId,
    required this.channelId,
    this.threadId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageView> {
  @override
  Widget build(BuildContext context) {
    Snowflake channelId = widget.channelId;
    if (widget.threadId != null) {
      channelId = widget.threadId!;
    }

    final channel = ref.watch(channelControllerProvider(channelId));
    if (channel is TextChannel) {
      return MessageList(
        guildId: widget.guildId,
        channelId: channelId,
        threadId: widget.threadId,
      );
    } else if (channel is ForumChannel) {
      return ForumView(guildId: widget.guildId, channelId: channelId);
    } else if (channel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Center(
          child: Text(
        'Select a channel',
        style: GoogleFonts.publicSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      )),
    );
  }
}
