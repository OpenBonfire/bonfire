import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/member/views/components/member_avatar.dart';
import 'package:bonfire/shared/utils/role_color.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberCard extends ConsumerStatefulWidget {
  final Member member;
  final Guild guild;
  final Channel channel;
  final bool roundTop;
  final bool roundBottom;
  const MemberCard({
    super.key,
    required this.member,
    required this.guild,
    required this.channel,
    required this.roundTop,
    required this.roundBottom,
  });

  @override
  ConsumerState<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends ConsumerState<MemberCard> {
  (String?, String?)? calculatePresenceMessage(List<Activity> activities) {
    if (activities.isEmpty) return null;

    final priorityOrder = [
      ActivityType.custom,
      ActivityType.streaming,
      ActivityType.game,
      ActivityType.listening,
      ActivityType.watching,
      ActivityType.competing
    ];

    var sortedActivities = activities.toList()
      ..sort((a, b) => priorityOrder
          .indexOf(a.type)
          .compareTo(priorityOrder.indexOf(b.type)));

    Activity highestPriorityActivity = sortedActivities.first;

    switch (highestPriorityActivity.type) {
      case ActivityType.custom:
        return (highestPriorityActivity.state, null);
      case ActivityType.streaming:
        return ("Streaming", highestPriorityActivity.name);
      case ActivityType.game:
        return ("Playing", highestPriorityActivity.name);
      case ActivityType.listening:
        return ("Listening to", highestPriorityActivity.name);
      case ActivityType.watching:
        return ("Watching", highestPriorityActivity.name);
      case ActivityType.competing:
        return ("Competing in", highestPriorityActivity.name);
      default:
        return null;
    }
  }

  Widget getStatusIcon(ClientStatus? clientStatus, UserStatus overallStatus) {
    const double iconSize = 16;
    const double containerSize = 20;
    Color statusColor;
    IconData statusIcon;
    ShapeBorder containerShape;

    // Determine the color based on the overall status
    switch (overallStatus) {
      case UserStatus.online:
        statusColor = Theme.of(context).custom.colorTheme.green;
        break;
      case UserStatus.idle:
        statusColor = Theme.of(context).custom.colorTheme.yellow;
        break;
      case UserStatus.dnd:
        statusColor = Theme.of(context).custom.colorTheme.red;
        break;
      case UserStatus.offline:
      default:
        statusColor = Theme.of(context).custom.colorTheme.foreground;
    }

    // Determine the icon and shape based on the client status
    if (clientStatus?.mobile == overallStatus) {
      statusIcon = Icons.phone_android;
      containerShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // Increased border radius
      );
    } else if (clientStatus?.desktop == overallStatus) {
      statusIcon = Icons.desktop_windows;
      containerShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // Increased border radius
      );
    } else if (clientStatus?.web == overallStatus) {
      statusIcon = Icons.language;
      containerShape = const CircleBorder();
    } else {
      // Default to circle if no specific client matches or clientStatus is null
      statusIcon = Icons.circle;
      containerShape = const CircleBorder();
    }

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: ShapeDecoration(
              color: Theme.of(context).custom.colorTheme.background,
              shape: containerShape,
            ),
          ),
          Icon(
            statusIcon,
            size: iconSize,
            color: statusColor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var roles =
        ref.watch(getGuildRolesProvider(widget.guild.id)).valueOrNull ?? [];

    PresenceUpdateEvent? initialPresence = widget.member.initialPresence;

    double borderRadiusTop = widget.roundTop ? 20 : 0;
    double borderRadiusBottom = widget.roundBottom ? 20 : 0;

    (String?, String?)? calculatedPresenceMessage;
    if (initialPresence?.activities != null) {
      calculatedPresenceMessage =
          calculatePresenceMessage(initialPresence!.activities!);
    }

    return Stack(
      children: [
        Container(
            height: 55,
            decoration: BoxDecoration(
              color: Theme.of(context).custom.colorTheme.messageBar,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadiusTop),
                topRight: Radius.circular(borderRadiusTop),
                bottomLeft: Radius.circular(borderRadiusBottom),
                bottomRight: Radius.circular(borderRadiusBottom),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Stack(
                    children: [
                      const SizedBox(width: 50, height: 50),
                      Center(
                        child: MemberAvatar(
                          guild: widget.guild,
                          channel: widget.channel,
                          member: widget.member,
                        ),
                      ),
                      Positioned(
                        right: 11,
                        bottom: 6,
                        child: getStatusIcon(
                          initialPresence?.clientStatus,
                          initialPresence?.status ?? UserStatus.offline,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.member.nick ??
                              widget.member.user?.globalName ??
                              widget.member.user?.username ??
                              "Unknown",
                          softWrap: false,
                          style: Theme.of(context)
                              .custom
                              .textTheme
                              .subtitle1
                              .copyWith(
                                  color: getRoleColor(widget.member, roles)),
                        ),
                        if (calculatedPresenceMessage != null)
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: GoogleFonts.publicSans(
                                color: Theme.of(context)
                                    .custom
                                    .colorTheme
                                    .deselectedChannelText,
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                              ),
                              children: [
                                if (calculatedPresenceMessage.$1 != null)
                                  TextSpan(
                                    text: "${calculatedPresenceMessage.$1} ",
                                    style: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                if (calculatedPresenceMessage.$2 != null)
                                  TextSpan(
                                    text: calculatedPresenceMessage.$2,
                                    style: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        if (!widget.roundTop)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 0.1,
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).custom.colorTheme.deselectedChannelText,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadiusTop),
                    topRight: Radius.circular(borderRadiusTop),
                    bottomLeft: Radius.circular(borderRadiusBottom),
                    bottomRight: Radius.circular(borderRadiusBottom),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
