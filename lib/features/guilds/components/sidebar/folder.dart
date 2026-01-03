import 'package:bonfire/features/guilds/components/sidebar/guild_item.dart';
import 'package:bonfire/features/guilds/components/sidebar/item.dart';
import 'package:bonfire/shared/components/buttons/no_splash.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuildFolderItem extends ConsumerStatefulWidget {
  final GuildFolder folder;
  const GuildFolderItem({super.key, required this.folder});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GuildFolderItemState();
}

class _GuildFolderItemState extends ConsumerState<GuildFolderItem> {
  //   late AnimationController _controller;
  // late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
  }

  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // return SidebarItem(
    //   selected: false,
    //   title: "Folder",
    //   child: Text(widget.folder.guildIds.toString()),
    // );
    if (widget.folder.id == null) {
      return GuildSidebarItem(guildId: widget.folder.guildIds.first);
    }
    // final items = widget.folder.guildIds
    //     .take(_expanded ? widget.folder.guildIds.length : 4)
    //     .map((e) => GuildSidebarItem(guildId: e))
    //     .toList();
    final items = widget.folder.guildIds
        .map((e) => GuildSidebarItem(guildId: e))
        .toList();
    final color = widget.folder.color != null
        ? Color(
            int.parse(widget.folder.color.toString(), radix: 10),
          ).withValues(alpha: 0.4)
        : theme.colorScheme.primary.withValues(alpha: 0.4);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(color: color),
      child: AnimatedSize(
        duration: Duration(milliseconds: 300),
        alignment: Alignment.topCenter,
        curve: Curves.easeInOut,
        child: Column(
          children: [
            if (_expanded) ...[
              NoSplashButton(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    top: 12,
                    bottom: 12,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SizedBox.expand(
                      child: Center(child: Icon(Icons.folder_rounded)),
                    ),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
              ...items,
            ] else
              SidebarItem(
                title: "Folder",
                selected: false,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(color: color),
                  child: AbsorbPointer(
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      children: items.toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
