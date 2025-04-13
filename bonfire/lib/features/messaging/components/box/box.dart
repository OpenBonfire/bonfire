import 'dart:typed_data';

import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/messaging/components/box/context_drawer.dart';
import 'package:bonfire/features/messaging/controllers/message.dart';
import 'package:bonfire/features/messaging/repositories/name.dart';
import 'package:bonfire/features/messaging/repositories/role_icon.dart';
import 'package:bonfire/features/messaging/components/box/avatar.dart';
import 'package:bonfire/features/messaging/components/box/content/attachment/attachment.dart';
import 'package:bonfire/features/messaging/components/box/content/embed/embed.dart';
import 'package:bonfire/features/messaging/components/box/markdown_box.dart';
import 'package:bonfire/features/messaging/components/box/popout.dart';
import 'package:bonfire/features/messaging/components/box/reply/message_reply.dart';
import 'package:bonfire/features/messaging/components/reactions.dart';
import 'package:bonfire/shared/components/drawer/mobile_drawer.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart' hide ButtonStyle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBox extends ConsumerStatefulWidget {
  final Snowflake messageId;
  final bool showSenderInfo;
  final Snowflake guildId;
  final Channel channel;
  const MessageBox({
    required this.guildId,
    required this.channel,
    super.key,
    required this.messageId,
    required this.showSenderInfo,
  });

  @override
  ConsumerState<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends ConsumerState<MessageBox>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;

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

  bool mentionsSelf(Message message) {
    var selfMember =
        ref.watch(getSelfMemberProvider(widget.guildId)).valueOrNull;
    if (selfMember == null) return false;

    bool directlyMentions =
        message.mentions.any((mention) => mention.id == selfMember.id);

    if (directlyMentions) return true;

    if (message.mentionsEveryone) return true;

    for (var role in message.roleMentionIds) {
      if (selfMember.roleIds.contains(role)) {
        return true;
      }
    }
    return false;
  }

  void showCustomRubberBottomSheet(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    Message? message = ref.watch(messageControllerProvider(widget.messageId));
    if (message == null) return const SizedBox.shrink();

    String? name = ref
            .watch(messageAuthorNameProvider(
                widget.guildId, widget.channel, message.author))
            .valueOrNull ??
        message.author.username;

    var member = ref
        .watch(getMemberProvider(widget.guildId, message.author.id))
        .valueOrNull;

    var roleIconRef = ref.watch(
      roleIconProvider(
        widget.guildId,
        message.author.id,
      ),
    );

    Color textColor = ref
            .watch(
              roleColorProvider(
                widget.guildId,
                message.author.id,
              ),
            )
            .valueOrNull ??
        Colors.white;

    Uint8List? roleIcon = roleIconRef.valueOrNull;

    name = member?.nick ?? member?.user?.globalName ?? name;

    bool mentioned = mentionsSelf(message);

    Widget buildBoxContent() {
      return Stack(
        children: [
          if (mentioned)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 2,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 252, 218, 155)),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
                left: mentioned ? 2 : 0,
                right: 16,
                top: mentioned ? 8 : 0,
                bottom: mentioned ? 4 : 0),
            child: Column(
              children: [
                if (message.referencedMessage != null && !isSmartwatch(context))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: MessageReply(
                      guildId: widget.guildId,
                      channel: widget.channel,
                      parentMessage: message,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: _buildMessageLayout(
                    context,
                    name!,
                    textColor,
                    message,
                    roleIcon,
                  ),
                ),
              ],
            ),
          ),
          if (_isHovering)
            Positioned(
              top: 0,
              right: 0,
              child: OverlayEntry(
                maintainState: true,
                builder: (context) => ContextPopout(
                  messageId: message.id,
                ),
              ).builder(context),
            ),
        ],
      );
    }

    Color boxColor = Colors.transparent;
    if (_isHovering) {
      boxColor =
          Theme.of(context).custom.colorTheme.foreground.withOpacity(0.8);
    }

    if (mentioned) {
      boxColor = const Color.fromARGB(255, 252, 218, 155).withOpacity(0.1);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Column(
        children: [
          SizedBox(height: widget.showSenderInfo ? 16 : 0),
          shouldUseMobileLayout(context)
              ? OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: boxColor,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    // change hover / select color to white
                    foregroundColor:
                        Theme.of(context).custom.colorTheme.foreground,
                  ),
                  onPressed: () {},
                  onLongPress: () {
                    if (shouldUseMobileLayout(context)) {
                      GlobalDrawer.of(context)!.toggleDrawer();
                      GlobalDrawer.of(context)!
                          .setChild(ContextDrawer(messageId: widget.messageId));
                    }
                  },
                  child: buildBoxContent(),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: buildBoxContent(),
                )
        ],
      ),
    );
  }

  Widget _buildMessageLayout(
    BuildContext context,
    String name,
    Color textColor,
    Message message,
    Uint8List? roleIcon,
  ) {
    bool isWatch = isSmartwatch(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                isWatch ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              if (widget.showSenderInfo)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Avatar(
                    author: message.author,
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
                    if (message.referencedMessage != null && isWatch)
                      MessageReply(
                        guildId: widget.guildId,
                        channel: widget.channel,
                        parentMessage: message,
                      ),
                    if (widget.showSenderInfo)
                      _buildMessageHeader(name, textColor, message, roleIcon),
                    if (!isWatch) _buildMessageContent(message),
                  ],
                ),
              ),
            ],
          ),
          if (isWatch)
            Align(
              alignment: Alignment.centerLeft,
              child: _buildMessageContent(message),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageHeader(
    String name,
    Color textColor,
    Message message,
    Uint8List? roleIcon,
  ) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: name,
                style: GoogleFonts.publicSans(
                  letterSpacing: 0.3,
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: '  '),
              TextSpan(
                text: dateTimeFormat(message.timestamp.toLocal()),
                style: GoogleFonts.publicSans(
                  letterSpacing: 0.3,
                  color: const Color.fromARGB(189, 255, 255, 255),
                  fontSize: 11,
                ),
              ),
              if (message.editedTimestamp != null)
                TextSpan(
                    text: " (edited)",
                    style: Theme.of(context).custom.textTheme.caption),
            ],
          ),
        ),
        if (roleIcon != null)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Image.memory(
              roleIcon,
              width: 18,
              height: 18,
            ),
          ),
      ],
    );
  }

  Widget _buildMessageContent(Message message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MessageMarkdownBox(message: message),
        ...message.embeds.map((embed) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: EmbedWidget(
                embed: embed,
              ),
            )),
        ...message.attachments.map((attachment) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AttachmentWidget(
                attachment: attachment,
              ),
            )),
        // const SizedBox(height: 4),
        MessageReactions(
          guildId: widget.guildId,
          messageId: widget.messageId,
        ),
      ],
    );
  }
}
