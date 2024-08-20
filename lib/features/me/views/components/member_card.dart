import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class DirectMessageMember extends ConsumerStatefulWidget {
  final PrivateChannel privateChannel;
  final Snowflake currentChannelId;
  const DirectMessageMember({
    super.key,
    required this.privateChannel,
    required this.currentChannelId,
  });

  @override
  ConsumerState<DirectMessageMember> createState() =>
      _DirectMessageMemberState();
}

class _DirectMessageMemberState extends ConsumerState<DirectMessageMember> {
  var lastGuildChannels = Hive.box("last-guild-channels");
  var lastLocation = Hive.box("last-location");

  @override
  Widget build(BuildContext context) {
    bool selected = widget.privateChannel.id == widget.currentChannelId;
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                side: const BorderSide(
                  color: Colors.transparent,
                  width: 0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                foregroundColor: selected
                    ? Theme.of(context).custom.colorTheme.selectedChannelText
                    : Theme.of(context).custom.colorTheme.deselectedChannelText,
                backgroundColor: selected
                    ? Theme.of(context).custom.colorTheme.foreground
                    : Colors.transparent),
            onPressed: () {
              HapticFeedback.selectionClick();
              lastGuildChannels.put(Snowflake.zero.toString(),
                  widget.privateChannel.id.toString());

              lastLocation.put("guildId", "@me");
              lastLocation.put(
                  "channelId", widget.privateChannel.id.toString());

              GoRouter.of(context)
                  .go('/channels/@me/${widget.privateChannel.id}');

              OverlappingPanelsState? overlappingPanelsState =
                  OverlappingPanels.of(context);
              if (overlappingPanelsState != null) {
                overlappingPanelsState.moveToState(RevealSide.main);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: Image.network(
                    widget.privateChannel.recipients.firstOrNull?.avatar.url
                            .toString() ??
                        "",
                    width: 35,
                    height: 35,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.privateChannel.recipients
                            .map((e) => e.globalName ?? e.username)
                            .join(', '),
                        style: Theme.of(context).custom.textTheme.subtitle1,
                        overflow: TextOverflow.ellipsis,
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
                ),
              ],
            )),
      ),
    );
  }
}
