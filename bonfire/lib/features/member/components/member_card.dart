import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/member/utils/show_member_dialog.dart';
import 'package:bonfire/features/user/components/presence_avatar.dart';
import 'package:bonfire/shared/utils/role_color.dart';
import 'package:bonfire/shared/components/presence_text.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  Widget build(BuildContext context) {
    var roles =
        ref.watch(getGuildRolesProvider(widget.guild.id)).valueOrNull ?? [];
    PresenceUpdateEvent? initialPresence = widget.member.initialPresence;

    double borderRadiusTop = widget.roundTop ? 20 : 0;
    double borderRadiusBottom = widget.roundBottom ? 20 : 0;

    return Stack(
      children: [
        OutlinedButton(
          onPressed: () {
            showMemberDialog(context, widget.member.user!.id, widget.guild.id);
          },
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.all(4),
            side: const BorderSide(
              color: Colors.transparent,
              width: 0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadiusTop),
                topRight: Radius.circular(borderRadiusTop),
                bottomLeft: Radius.circular(borderRadiusBottom),
                bottomRight: Radius.circular(borderRadiusBottom),
              ),
            ),
            foregroundColor: Theme.of(context).custom.colorTheme.dirtyWhite,
            backgroundColor: Theme.of(context).custom.colorTheme.foreground,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const SizedBox(
                  width: 6,
                  height: 58,
                ),
                PresenceAvatar(
                  user: widget.member.user!,
                  initialPresence: initialPresence,
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
                      PresenceText(
                        userid: widget.member.user!.id,
                        initialPresence: initialPresence,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!widget.roundTop)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 0.1,
                decoration: BoxDecoration(
                  color: Theme.of(context).custom.colorTheme.gray,
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
