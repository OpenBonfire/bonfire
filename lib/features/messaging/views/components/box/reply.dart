import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/messaging/views/components/box/avatar.dart';
import 'package:bonfire/shared/utils/role_color.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageReply extends ConsumerWidget {
  final Message parentMessage;
  final Guild guild;
  final Channel channel;
  const MessageReply(
      {super.key,
      required this.parentMessage,
      required this.guild,
      required this.channel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var author = parentMessage.referencedMessage!.author;
    var member = ref.watch(getMemberProvider(guild, author.id));
    var roles = ref.watch(getGuildRolesProvider(guild)).valueOrNull ?? [];

    String name = author.username;
    Color textColor = Colors.white;

    member.when(
      data: (member) {
        name = member?.nick ?? member?.user?.globalName ?? name;
        textColor = getRoleColor(member!, roles);
      },
      loading: () {},
      error: (error, stack) {},
    );

    return Padding(
      padding: const EdgeInsets.only(left: 72, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(
            author: parentMessage.referencedMessage!.author,
            guildId: guild.id,
            channelId: channel.id,
            width: 15,
            height: 15,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$name ',
                    style: GoogleFonts.publicSans(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: parentMessage.referencedMessage!.content,
                    style: GoogleFonts.publicSans(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
