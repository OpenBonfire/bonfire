import 'package:bonfire/features/user/components/user_avatar.dart';
import 'package:bonfire/features/user/controllers/user.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PresenceAvatar extends ConsumerStatefulWidget {
  final User user;
  final PresenceUpdateEvent? initialPresence;
  final double? size;
  const PresenceAvatar({
    super.key,
    required this.user,
    this.initialPresence,
    this.size,
  });

  @override
  ConsumerState<PresenceAvatar> createState() => _PresenceAvatarState();
}

class _PresenceAvatarState extends ConsumerState<PresenceAvatar> {
  Widget getStatusIcon(ClientStatus? clientStatus, UserStatus overallStatus) {
    double iconSize = widget.size != null ? (widget.size! / 5) : 14;
    Color statusColor;
    IconData statusIcon;
    ShapeBorder containerShape;
    EdgeInsetsGeometry padding = const EdgeInsets.all(1);

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
        statusColor = Theme.of(context).custom.colorTheme.foreground;
    }

    if (clientStatus?.mobile == overallStatus) {
      statusIcon = Icons.phone_android;
      containerShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      );
      padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 1);
    } else if (clientStatus?.desktop == overallStatus) {
      statusIcon = Icons.desktop_windows;
      containerShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      );
    } else if (clientStatus?.web == overallStatus) {
      statusIcon = Icons.language;
      containerShape = const CircleBorder();
    } else {
      statusIcon = Icons.circle;
      containerShape = const CircleBorder();
    }

    return Container(
      decoration: ShapeDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        shape: containerShape,
      ),
      child: Padding(
        padding: padding,
        child: Icon(
          statusIcon,
          size: iconSize,
          color: statusColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var initialPresence = widget.initialPresence;
    return Stack(
      alignment: Alignment.center,
      children: [
        // const SizedBox(width: 38, height: 38),
        Center(
          child: UserAvatar(
            user: widget.user,
            size: widget.size ?? 35,
          ),
        ),
        Positioned(
          right: widget.size != null ? (widget.size! / 20) : 0,
          bottom: widget.size != null ? (widget.size! / 20) : 0,
          child: getStatusIcon(
            initialPresence?.clientStatus,
            initialPresence?.status ?? UserStatus.offline,
          ),
        )
      ],
    );
  }
}
