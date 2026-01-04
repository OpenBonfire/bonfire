import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:bonfire/features/guilds/components/sidebar/guild_item.dart';
import 'package:bonfire/features/guilds/components/sidebar/item.dart';
import 'package:bonfire/features/media/components/image.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    final rawGuildId = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.pathParameters["guildId"];
    Snowflake? selectedGuildId;
    try {
      selectedGuildId = Snowflake.parse(rawGuildId!);
    } catch (e) {}

    final items = _expanded
        ? widget.folder.guildIds
              .map(
                (e) => GuildSidebarItem(
                  guildId: e,
                  padding: .only(left: 2, right: 4),
                ),
              )
              .toList()
        : widget.folder.guildIds
              .take(4)
              .map((e) => _GuildIcon(guildId: e))
              .toList();
    final color = widget.folder.color != null
        ? Color(
            int.parse(widget.folder.color.toString(), radix: 10),
          ).withValues(alpha: 0.3)
        : theme.colorScheme.primary.withValues(alpha: 0.3);

    final selected =
        selectedGuildId != null &&
        widget.folder.guildIds.contains(selectedGuildId) &&
        !_expanded;

    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          left: 10,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: .circular(20),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SidebarItem(
                  title: "Folder",
                  selectedRadiusFactor: 0.38,
                  deselectedRadiusFactor: 0.38,
                  selected: selected,
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
                              padding: .all(5),
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 2,
                              crossAxisCount: 2,
                              children: items.take(4).toList(),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: _animation.value.clamp(0.0, 1.0),
                          child: Center(
                            child: Icon(
                              Icons.folder_rounded,
                              color: color.withAlpha(255),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizeTransition(
                  sizeFactor: _animation,
                  axisAlignment: -1.0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Column(spacing: 4, children: items),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GuildIcon extends ConsumerWidget {
  final Snowflake guildId;
  const _GuildIcon({super.key, required this.guildId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guild = ref.watch(guildProvider(guildId))!;
    final client = ref.watch(clientControllerProvider)!;
    return guild.icon != null
        ? DiscordNetworkImage(
            guild.icon!.getUrl(client).toString(),
            borderRadius: .circular(8),
          )
        : Text("rah");
  }
}
