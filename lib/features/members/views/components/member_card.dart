import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/members/views/components/member_avatar.dart';
import 'package:bonfire/shared/utils/role_color.dart';
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

    double borderRadiusTop = widget.roundTop ? 8 : 0;
    double borderRadiusBottom = widget.roundBottom ? 8 : 0;

    return Container(
        height: 55,
        decoration: BoxDecoration(
          color: Theme.of(context).custom.colorTheme.messageBar,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadiusTop),
              topRight: Radius.circular(borderRadiusTop),
              bottomLeft: Radius.circular(borderRadiusBottom),
              bottomRight: Radius.circular(borderRadiusBottom)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            // widget.member.avatar.url
            children: [
              MemberAvatar(
                  guild: widget.guild,
                  channel: widget.channel,
                  member: widget.member),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.member.nick ??
                        widget.member.user?.globalName ??
                        widget.member.user?.username ??
                        "Unknown",
                    style: Theme.of(context)
                        .custom
                        .textTheme
                        .subtitle1
                        .copyWith(color: getRoleColor(widget.member, roles)),
                  ),
                  // Text(
                  //   widget.member.status,
                  //   style: Theme.of(context).custom.textTheme.subtitle2,
                  // ),
                ],
              ),
            ],
          ),
        ));
  }
}
