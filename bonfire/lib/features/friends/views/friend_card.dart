import 'package:bonfire/features/user/components/presence_avatar.dart';
import 'package:bonfire/features/user/controllers/presence.dart';
import 'package:bonfire/shared/components/presence_text.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendCard extends ConsumerStatefulWidget {
  final Relationship relationship;
  const FriendCard({
    super.key,
    required this.relationship,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FriendCardState();
}

class _FriendCardState extends ConsumerState<FriendCard> {
  @override
  Widget build(BuildContext context) {
    PresenceUpdateEvent? presence =
        ref.watch(presenceControllerProvider(widget.relationship.user.id));
    print(widget.relationship.user.username);
    // var privateMessages = ref.watch(privateMessageHistoryProvider);
    // print(privateMessages.first.recipients.first);

    // I need a way of getting the dm channel ID from the user ID
    // var dm = privateMessages.first.recipients
    //     .where((element) => element.id == widget.relationship.user.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.all(4),
          side: const BorderSide(
            color: Colors.transparent,
            width: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          foregroundColor:
              Theme.of(context).custom.colorTheme.selectedChannelText,
          backgroundColor: Theme.of(context).custom.colorTheme.foreground,
        ),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: PresenceAvatar(
                user: widget.relationship.user,
                initialPresence: presence,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.relationship.user.username,
                    style: Theme.of(context).custom.textTheme.subtitle1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  PresenceText(
                    userid: widget.relationship.user.id,
                    initialPresence: presence,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
