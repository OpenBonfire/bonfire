import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupHeader extends ConsumerStatefulWidget {
  final GuildMemberListGroup group;
  final List<GuildMemberListGroup> groups;
  const GroupHeader({super.key, required this.group, required this.groups});

  @override
  ConsumerState<GroupHeader> createState() => _HeaderCardState();
}

class _HeaderCardState extends ConsumerState<GroupHeader> {
  @override
  Widget build(BuildContext context) {
    var role = ref.watch(getRoleProvider(widget.group.id!)).valueOrNull;
    int groupCount = 0;
    for (var group in widget.groups) {
      for (var element in widget.groups) {
        if (element.id == widget.group.id) {
          groupCount = element.count!;
        }
      }
    }
    return Container(
      child: Text("${role?.name} - ${groupCount}",
          style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).custom.colorTheme.buttonIcon1)),
    );
  }
}
