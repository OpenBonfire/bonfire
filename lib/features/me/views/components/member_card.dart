import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DirectMessageMember extends ConsumerStatefulWidget {
  final PrivateChannel privateChannel;
  const DirectMessageMember({super.key, required this.privateChannel});

  @override
  ConsumerState<DirectMessageMember> createState() =>
      _DirectMessageMemberState();
}

class _DirectMessageMemberState extends ConsumerState<DirectMessageMember> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              side: BorderSide(
                color: Theme.of(context).custom.colorTheme.foreground,
                // color: (widget.channel.id == widget.currentChannelId)
                //     ? Theme.of(context).custom.colorTheme.deselectedChannelText
                //     : Colors.transparent,

                width: 0.1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor:
                  Theme.of(context).custom.colorTheme.deselectedChannelText,
              backgroundColor: Colors.transparent,
            ),
            onPressed: () {
              print("navigating!");
              GoRouter.of(context)
                  .go('/channels/@me/${widget.privateChannel.id}');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: Image.network(
                    widget.privateChannel.recipients.first.avatar.url
                        .toString(),
                    width: 35,
                    height: 35,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.privateChannel.recipients
                          .map((e) => e.globalName ?? e.username)
                          .join(', '),
                      style: GoogleFonts.publicSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Status placeholder",
                      style: GoogleFonts.publicSans(
                        color: Theme.of(context)
                            .custom
                            .colorTheme
                            .deselectedChannelText,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
