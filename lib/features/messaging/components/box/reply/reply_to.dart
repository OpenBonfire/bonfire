import 'package:bonfire/features/messaging/controllers/message.dart';
import 'package:bonfire/features/messaging/controllers/reply.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ReplyTo extends ConsumerStatefulWidget {
  final Snowflake messageId;
  final bool shouldMention;

  const ReplyTo({
    super.key,
    required this.messageId,
    required this.shouldMention,
  });

  @override
  ConsumerState<ReplyTo> createState() => _ReplyToState();
}

class _ReplyToState extends ConsumerState<ReplyTo> {
  @override
  Widget build(BuildContext context) {
    Message message = ref.watch(messageControllerProvider(widget.messageId))!;
    return Container(
        height: 40,
        decoration: BoxDecoration(
          color: BonfireThemeExtension.of(context).foreground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Row(
            children: [
              Text(
                "Replying to",
                style: GoogleFonts.publicSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                message.author.username,
                style: GoogleFonts.publicSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(4),
                  side: const BorderSide(
                    color: Colors.transparent,
                    width: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: BonfireThemeExtension.of(context).dirtyWhite,
                  backgroundColor: BonfireThemeExtension.of(context).foreground,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(replyControllerProvider.notifier)
                      .setMessageReply(null);
                },
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                ),
              ),
            ],
          ),
        ));
  }
}
