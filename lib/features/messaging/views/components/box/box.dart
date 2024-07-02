import 'dart:io';

import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/messaging/views/components/box/avatar.dart';
import 'package:bonfire/features/messaging/views/components/box/content/attachment/attachment.dart';
import 'package:bonfire/features/messaging/views/components/box/content/embed/embed.dart';
import 'package:bonfire/features/messaging/views/components/box/curved_line_painter.dart';
import 'package:bonfire/features/messaging/views/components/box/markdown_box.dart';
import 'package:bonfire/features/messaging/views/components/box/reply.dart';
import 'package:bonfire/shared/utils/role_color.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBox extends ConsumerStatefulWidget {
  final Message? message;
  final bool showSenderInfo;
  final Guild guild;
  final Channel channel;
  const MessageBox({
    required this.guild,
    required this.channel,
    super.key,
    required this.message,
    required this.showSenderInfo,
  });

  @override
  ConsumerState<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends ConsumerState<MessageBox> {
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

  @override
  Widget build(BuildContext context) {
    var embeds = widget.message!.embeds;
    var attachments = widget.message!.attachments;

    String name = widget.message!.author.username;

    Color textColor = Colors.white;

    var member =
        ref.watch(getMemberProvider(widget.guild, widget.message!.author.id));
    var roles =
        ref.watch(getGuildRolesProvider(widget.guild)).valueOrNull ?? [];

    String? roleIconUrl;

    member.when(
      data: (member) {
        name = member?.nick ?? member?.user?.globalName ?? name;
        textColor = getRoleColor(member!, roles);
        roleIconUrl = getRoleIconUrl(member, roles);
      },
      loading: () {},
      error: (error, stack) {},
    );

    return Column(
      children: [
        SizedBox(
          height: widget.showSenderInfo ? 16 : 0,
        ),
        (widget.message!.referencedMessage != null)
            ? Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: MessageReply(
                      guild: widget.guild,
                      channel: widget.channel,
                      parentMessage: widget.message!,
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: const BorderSide(
              color: Color.fromARGB(0, 255, 255, 255),
              width: 0.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (widget.showSenderInfo == true)
                  ? Avatar(
                      // key: Key(widget.message!.author.avatarHash ?? ""),
                      author: widget.message!.author,
                      guildId: widget.guild.id,
                      channelId: widget.channel.id,
                    )
                  : const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 45,
                      ),
                    ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.showSenderInfo
                        ? Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  name,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (roleIconUrl != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 6, top: 2),
                                  child: Image.network(
                                    roleIconUrl!,
                                    width: 22,
                                    height: 22,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(left: 6, top: 4),
                                child: Text(
                                  dateTimeFormat(
                                      widget.message!.timestamp.toLocal()),
                                  textAlign: TextAlign.left,
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                    color: Color.fromARGB(189, 255, 255, 255),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(left: 6, top: 0),
                      child: SizedBox(
                        child: MarkdownBox(
                          message: widget.message,
                        ),
                      ),
                    ),
                    for (var embed in embeds)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 8),
                        child: EmbedWidget(
                          embed: embed,
                        ),
                      ),
                    for (var attachment in attachments)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 8),
                        child: AttachmentWidget(
                          attachment: attachment,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
