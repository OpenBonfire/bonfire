import 'package:bonfire/features/guilds/components/sidebar/guild_item.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuildFolderItem extends ConsumerStatefulWidget {
  final GuildFolder folder;
  const GuildFolderItem({super.key, required this.folder});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GuildFolderItemState();
}

class _GuildFolderItemState extends ConsumerState<GuildFolderItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    // return SidebarItem(
    //   selected: false,
    //   title: "Folder",
    //   child: Text(widget.folder.guildIds.toString()),
    // );
    if (widget.folder.id == null) {
      return GuildSidebarItem(guildId: widget.folder.guildIds.first);
    }
    final items = widget.folder.guildIds
        .map((e) => GuildSidebarItem(guildId: e))
        .toList();
    if (!_expanded) {
      return GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        children: items.take(4).toList(),
      );
    }
    return Column(children: items);
  }
}
