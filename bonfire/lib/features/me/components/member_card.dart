import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/features/user/components/presence_avatar.dart';
import 'package:bonfire/features/user/controllers/presence.dart';
import 'package:bonfire/shared/components/presence_text.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';

class DirectMessageMember extends ConsumerStatefulWidget {
  final Channel privateChannel;
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
    List<User>? recipients;

    if (widget.privateChannel is DmChannel) {
      recipients = (widget.privateChannel as DmChannel).recipients;
    } else if (widget.privateChannel is GroupDmChannel) {
      recipients = (widget.privateChannel as GroupDmChannel).recipients;
    } else {
      print("VERY BAD! Recipients is null");
    }

    Snowflake userId = recipients!.firstOrNull?.id ?? Snowflake.zero;

    PresenceUpdateEvent? presence =
        ref.watch(presenceControllerProvider(userId));

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
      child: SizedBox(
        width: double.infinity,
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
              print("routing: ${widget.privateChannel.id.toString()}");
              GoRouter.of(context)
                  .go('/channels/@me/${widget.privateChannel.id}');

              OverlappingPanelsState? overlappingPanelsState =
                  OverlappingPanels.of(context);
              if (overlappingPanelsState != null) {
                overlappingPanelsState.moveToState(RevealSide.main);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // TODO: Check type if dm / group dm / etc, and work from there
                  // I think it'll parse but it might be slightly different from a bot
                  Center(
                    child: PresenceAvatar(
                      initialPresence: presence,
                      user: recipients.firstOrNull!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          recipients
                              .map((e) => e.globalName ?? e.username)
                              .join(', '),
                          style: Theme.of(context).custom.textTheme.subtitle1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        PresenceText(
                          userid: userId,
                          initialPresence: presence,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
