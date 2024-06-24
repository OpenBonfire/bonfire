import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/members/views/components/member_avatar.dart';
import 'package:bonfire/shared/utils/role_color.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberCard extends ConsumerStatefulWidget {
  final Member member;
  const MemberCard({
    super.key,
    required this.member,
  });

  @override
  ConsumerState<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends ConsumerState<MemberCard> {
  @override
  Widget build(BuildContext context) {
    var roles = ref.watch(getGuildRolesProvider).valueOrNull ?? [];

    return Container(
        height: 55,
        decoration: BoxDecoration(
          color: Theme.of(context).custom.colorTheme.messageBar,
          borderRadius: const BorderRadius.all(
            Radius.circular(18),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            // widget.member.avatar.url
            children: [
              MemberAvatar(member: widget.member),
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
                        .copyWith(
                            color: getRoleColor(
                                widget.member, roles as List<Role>)),
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
