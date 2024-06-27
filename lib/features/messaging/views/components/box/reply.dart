import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/messaging/views/components/box/avatar.dart';
import 'package:bonfire/shared/utils/role_color.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageReply extends ConsumerWidget {
  final Message parentMessage;
  const MessageReply({super.key, required this.parentMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var author = parentMessage.referencedMessage!.author;
    var member = ref.watch(getMemberProvider(author.id));
    var roles = ref.watch(getGuildRolesProvider).valueOrNull ?? [];

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
        // align to top
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                  author: parentMessage.referencedMessage!.author,
                  width: 15,
                  height: 15),
              Text(
                name,
                style: GoogleFonts.openSans(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                width: 6,
              ),
            ],
          ),
          Flexible(
            child: Text(
              parentMessage.referencedMessage!.content,
              style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
