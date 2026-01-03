import 'package:bonfire/features/guilds/components/sidebar/guild_item.dart';
import 'package:bonfire/features/guilds/components/sidebar/item.dart';
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

class _GuildFolderItemState extends ConsumerState<GuildFolderItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.folder.id == null) {
      return GuildSidebarItem(guildId: widget.folder.guildIds.first);
    }

    final items = widget.folder.guildIds
        .map((e) => GuildSidebarItem(guildId: e))
        .toList();
    final color = widget.folder.color != null
        ? Color(
            int.parse(widget.folder.color.toString(), radix: 10),
          ).withValues(alpha: 0.4)
        : theme.colorScheme.primary.withValues(alpha: 0.4);

    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          left: 10,
          right: 0,
          child: Container(decoration: BoxDecoration(color: color)),
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SidebarItem(
                  title: "Folder",
                  selected: false,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _toggleExpand();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        color,
                        Colors.transparent,
                        _animation.value,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: (1 - _animation.value).clamp(0.0, 1.0),
                          child: AbsorbPointer(
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              children: items.take(4).toList(),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: _animation.value.clamp(0.0, 1.0),
                          child: const Center(
                            child: Icon(Icons.folder_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizeTransition(
                  sizeFactor: _animation,
                  axisAlignment: -1.0,
                  child: Column(children: items),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
