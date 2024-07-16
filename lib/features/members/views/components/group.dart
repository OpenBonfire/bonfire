import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupHeader extends ConsumerStatefulWidget {
  final GuildMemberListGroup group;
  final Guild guild;
  final List<GuildMemberListGroup> groups;
  const GroupHeader(
      {super.key,
      required this.guild,
      required this.group,
      required this.groups});

  @override
  ConsumerState<GroupHeader> createState() => _HeaderCardState();
}

class _HeaderCardState extends ConsumerState<GroupHeader> {
  @override
  Widget build(BuildContext context) {
    Role? role;
    // TODO: Online members should be in a group...
    if (widget.group.id != null) {
      role = ref
          .watch(getRoleProvider(widget.guild, widget.group.id!))
          .valueOrNull;
    }
    int groupCount = 0;
    for (var group in widget.groups) {
      for (var element in widget.groups) {
        if (element.id == widget.group.id) {
          groupCount = element.count!;
        }
      }
    }

    return Text("${role?.name ?? widget.group.name} - $groupCount",
        style: GoogleFonts.publicSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).custom.colorTheme.buttonIcon1));
  }
}
