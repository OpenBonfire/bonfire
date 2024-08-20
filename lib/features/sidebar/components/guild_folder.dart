import 'package:bonfire/features/guild/repositories/guild_mentions.dart';
import 'package:bonfire/features/guild/repositories/guild_unreads.dart';
import 'package:bonfire/features/sidebar/components/folder_icon.dart';
import 'package:bonfire/features/sidebar/components/sidebar_icon.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex/hex.dart';

class GuildFolderWidget extends ConsumerStatefulWidget {
  final GuildFolder guildFolder;
  final List<UserGuild> guildList;
  final Snowflake selectedGuildId;

  const GuildFolderWidget({
    super.key,
    required this.guildFolder,
    required this.guildList,
    required this.selectedGuildId,
  });

  @override
  GuildFolderWidgetState createState() => GuildFolderWidgetState();
}

class GuildFolderWidgetState extends ConsumerState<GuildFolderWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  double _iconHeight = 8;
  double iconSpacing = 6.0;

  bool _hasUnreadsInFolder(List<UserGuild> folderGuilds, WidgetRef ref) {
    for (var guild in folderGuilds) {
      if (ref.read(guildUnreadsProvider(guild.id)).valueOrNull ?? false) {
        return true;
      }
    }
    return false;
  }

  int _getTotalMentionsInFolder(List<UserGuild> folderGuilds, WidgetRef ref) {
    int totalMentions = 0;
    for (var guild in folderGuilds) {
      totalMentions +=
          ref.read(guildMentionsProvider(guild.id)).valueOrNull ?? 0;
    }
    return totalMentions;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMentionBubble(int count) {
    return Container(
      width: 23,
      height: 23,
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).custom.colorTheme.red,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Center(
              child: Text(
                count.toString(),
                style: Theme.of(context).custom.textTheme.bodyText1.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<UserGuild> folderGuilds = widget.guildList
        .where((guild) => widget.guildFolder.guildIds.contains(guild.id))
        .toList();

    if (folderGuilds.isEmpty) return const SizedBox.shrink();

    if (folderGuilds.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: SidebarIcon(
          selected: widget.selectedGuildId == folderGuilds[0].id,
          guild: folderGuilds[0],
          isClickable: true,
        ),
      );
    }

    bool hasUnreadsInFolder = _hasUnreadsInFolder(folderGuilds, ref);
    int totalMentions = _getTotalMentionsInFolder(folderGuilds, ref);

    setState(() {
      if (hasUnreadsInFolder && !_isExpanded) {
        _iconHeight = 8;
      }
    });

    return Stack(
      children: [
        Column(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _isExpanded = !_isExpanded;
                    if (_isExpanded) {
                      _controller.forward();
                    } else {
                      _controller.reverse();
                    }
                  });
                },
                child: AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, child) {
                    return Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: 1 - _expandAnimation.value,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: (widget.guildFolder.color != null)
                                          ? Color(int.parse(
                                                  widget.guildFolder.color
                                                      .toString(),
                                                  radix: 10))
                                              .withOpacity(0.5)
                                          : Theme.of(context)
                                              .custom
                                              .colorTheme
                                              .blurple
                                              .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    width: 50,
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: GridView.count(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        children:
                                            folderGuilds.take(4).map((guild) {
                                          return Center(
                                            child: SidebarIcon(
                                              selected:
                                                  widget.selectedGuildId ==
                                                      guild.id,
                                              guild: guild,
                                              mini: true,
                                              isClickable: false,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: _expandAnimation.value,
                                child: Center(
                                  child: FolderIcon(
                                    color: (widget.guildFolder.color != null)
                                        ? Color(int.parse(
                                                widget.guildFolder.color
                                                    .toString(),
                                                radix: 10))
                                            .withOpacity(1)
                                        : Color(
                                            Theme.of(context)
                                                .custom
                                                .colorTheme
                                                .blurple
                                                .value,
                                          ),
                                  ),
                                ),
                              ),
                              if (totalMentions > 0 && !_isExpanded)
                                Positioned(
                                  right: 8,
                                  bottom: -3,
                                  child: _buildMentionBubble(totalMentions),
                                ),
                            ],
                          ),
                          SizeTransition(
                            sizeFactor: _expandAnimation,
                            child: Column(
                              children: (folderGuilds
                                  .map(
                                    (guild) => SizedBox(
                                      child: Center(
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(top: iconSpacing),
                                          child: SidebarIcon(
                                            selected: widget.selectedGuildId ==
                                                guild.id,
                                            guild: guild,
                                            isClickable: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList() as List<Widget>)
                                ..add(
                                  const SizedBox(height: 4),
                                ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // SizedBox(height: _isExpanded ? 0 : 4),
          ],
        ),
        if (!_isExpanded && hasUnreadsInFolder)
          Positioned(
            left: 0,
            top: 2,
            bottom: 4,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOutExpo,
                width: 4,
                height: _iconHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
