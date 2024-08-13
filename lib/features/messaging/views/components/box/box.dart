import 'dart:typed_data';

import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/messaging/repositories/name.dart';
import 'package:bonfire/features/messaging/repositories/role_icon.dart';
import 'package:bonfire/features/messaging/views/components/box/avatar.dart';
import 'package:bonfire/features/messaging/views/components/box/content/attachment/attachment.dart';
import 'package:bonfire/features/messaging/views/components/box/content/embed/embed.dart';
import 'package:bonfire/features/messaging/views/components/box/markdown_box.dart';
import 'package:bonfire/features/messaging/views/components/box/popout.dart';
import 'package:bonfire/features/messaging/views/components/box/reply.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart' hide ButtonStyle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageBox extends ConsumerStatefulWidget {
  final Message? message;
  final bool showSenderInfo;
  final Snowflake guildId;
  final Channel channel;
  const MessageBox({
    required this.guildId,
    required this.channel,
    super.key,
    required this.message,
    required this.showSenderInfo,
  });

  @override
  ConsumerState<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends ConsumerState<MessageBox> {
  bool _isHovering = false;

  @override
  void initState() {
    // print("box init!");
    super.initState();
  }

  String dateTimeFormat(DateTime time) {
    String section1;
    String section2;

    if (time.day == DateTime.now().day) {
      section1 = 'Today';
    } else if (time.day == DateTime.now().day - 1) {
      section1 = 'Yesterday';
    } else {
      section1 = '${time.month}/${time.day}/${time.year}';
    }

    int twelveHour = time.hour % 12;
    twelveHour = twelveHour == 0 ? 12 : twelveHour;
    String section3 = time.hour >= 12 ? 'PM' : 'AM';

    String formattedMinute =
        time.minute < 10 ? '0${time.minute}' : '${time.minute}';
    section2 = ' at $twelveHour:$formattedMinute $section3';

    return section1 + section2;
  }

  bool mentionsSelf() {
    var selfMember =
        ref.watch(getSelfMemberProvider(widget.guildId)).valueOrNull;
    if (selfMember == null) return false;

    bool directlyMentions =
        widget.message!.mentions.any((mention) => mention.id == selfMember.id);

    if (directlyMentions) return true;

    if (widget.message!.mentionsEveryone) return true;

    for (var role in widget.message!.roleMentionIds) {
      if (selfMember.roleIds.contains(role)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    String? name = ref
            .watch(messageAuthorNameProvider(
                widget.guildId, widget.channel, widget.message!.author))
            .valueOrNull ??
        widget.message!.author.username;

    var member = ref
        .watch(getMemberProvider(widget.guildId, widget.message!.author.id))
        .valueOrNull;

    var roleIconRef = ref.watch(roleIconProvider(
      widget.guildId,
      widget.message!.author.id,
    ));

    Color textColor = ref
            .watch(roleColorProvider(
              widget.guildId,
              widget.message!.author.id,
            ))
            .valueOrNull ??
        Colors.white;

    Uint8List? roleIcon = roleIconRef.valueOrNull;

    name = member?.nick ?? member?.user?.globalName ?? name;

    bool mentioned = mentionsSelf();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Column(
        children: [
          SizedBox(height: widget.showSenderInfo ? 16 : 0),
          if (widget.message!.referencedMessage != null)
            MessageReply(
              guildId: widget.guildId,
              channel: widget.channel,
              parentMessage: widget.message!,
            ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: mentioned
                  ? Colors.yellow.withOpacity(0.1)
                  : Colors.transparent,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              // change hover / select color to white
              foregroundColor: Theme.of(context).custom.colorTheme.foreground,
            ),
            onPressed: () {},
            child: Stack(
              children: [
                if (mentioned)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 2,
                        decoration: const BoxDecoration(color: Colors.yellow),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    left: mentioned ? 2 : 0,
                    right: 16,
                  ),
                  child:
                      _buildMessageLayout(context, name, textColor, roleIcon),
                ),
                if (_isHovering)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: OverlayEntry(
                      maintainState: true,
                      builder: (context) => const ContextPopout(),
                    ).builder(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageLayout(
      BuildContext context, String name, Color textColor, Uint8List? roleIcon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(width: 8.0),
          if (widget.showSenderInfo)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Avatar(
                author: widget.message!.author,
                guildId: widget.guildId,
                channelId: widget.channel.id,
              ),
            )
          else
            const SizedBox(width: 40),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showSenderInfo)
                  _buildMessageHeader(name, textColor, roleIcon),
                _buildMessageContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageHeader(
      String name, Color textColor, Uint8List? roleIcon) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: '  '),
              TextSpan(
                text: dateTimeFormat(widget.message!.timestamp.toLocal()),
                style: const TextStyle(
                  color: Color.fromARGB(189, 255, 255, 255),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (roleIcon != null)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Image.memory(
              roleIcon,
              width: 22,
              height: 22,
            ),
          ),
      ],
    );
  }

  Widget _buildMessageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MessageMarkdownBox(message: widget.message!),
        ...widget.message!.embeds.map((embed) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: EmbedWidget(
                embed: embed,
              ),
            )),
        ...widget.message!.attachments.map((attachment) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AttachmentWidget(
                attachment: attachment,
              ),
            )),
      ],
    );
  }
}
