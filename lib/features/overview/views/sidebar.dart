import 'package:bonfire/features/guild/repositories/guild.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebridge/firebridge.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends ConsumerStatefulWidget {
  final Snowflake guildId;
  const Sidebar({super.key, required this.guildId});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  UserGuild? previousSelectedGuild;

  @override
  Widget build(BuildContext context) {
    var guildWatch = ref.watch(guildsProvider);
    var guildFoldersWatch = ref.watch(guildFoldersProvider);

    List<UserGuild> guildList = [];
    guildWatch.when(
        data: (guilds) {
          guildList = guilds;
        },
        error: (data, trace) {},
        loading: () {});

    List<GuildFolder>? guildFolders = guildFoldersWatch;

    return Column(
      children: [
        Expanded(
          child: SizedBox(
            width: 70,
            height: double.infinity,
            child: Center(
                child: SizedBox(
              width: 55,
              child: (guildFolders != null)
                  ? ListView.builder(
                      itemCount: guildFolders.length,
                      itemBuilder: (context, index) {
                        return GuildFolderWidget(
                          guildFolder: guildFolders[index],
                          guildList: guildList,
                          selectedGuildId: widget.guildId,
                        );
                      },
                    )
                  : const SizedBox(),
            )),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).padding.bottom + 50,
        )
      ],
    );
  }
}

class GuildFolderWidget extends StatefulWidget {
  final GuildFolder guildFolder;
  final List<UserGuild> guildList;
  final Snowflake selectedGuildId;

  const GuildFolderWidget({
    Key? key,
    required this.guildFolder,
    required this.guildList,
    required this.selectedGuildId,
  }) : super(key: key);

  @override
  _GuildFolderWidgetState createState() => _GuildFolderWidgetState();
}

class _GuildFolderWidgetState extends State<GuildFolderWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

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

  @override
  Widget build(BuildContext context) {
    List<UserGuild> folderGuilds = widget.guildList
        .where((guild) => widget.guildFolder.guildIds.contains(guild.id))
        .toList();

    // If there's only one guild in the folder, treat it as a regular server icon
    if (folderGuilds.length == 1) {
      return SidebarIcon(
        selected: widget.selectedGuildId == folderGuilds[0].id,
        guild: folderGuilds[0],
        isClickable: true,
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
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
              return Column(
                children: [
                  if (_expandAnimation.value > 0)
                    Opacity(
                      opacity: _expandAnimation.value,
                      child: FolderIcon(
                        color: Color(widget.guildFolder.color ??
                            Theme.of(context).custom.colorTheme.blurple.value),
                      ),
                    ),
                  if (_expandAnimation.value < 1)
                    Opacity(
                      opacity: 1 - _expandAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .custom
                              .colorTheme
                              .blurple
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        width: 55,
                        height: 55,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: GridView.count(
                            crossAxisCount: 2,
                            children: folderGuilds.take(4).map((guild) {
                              return SidebarIcon(
                                selected: widget.selectedGuildId == guild.id,
                                guild: guild,
                                mini: true,
                                isClickable: false,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: Column(
                      children: folderGuilds
                          .map((guild) => Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: SidebarIcon(
                                  selected: widget.selectedGuildId == guild.id,
                                  guild: guild,
                                  isClickable: true,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: _isExpanded ? 0 : 4),
      ],
    );
  }
}

class FolderIcon extends StatelessWidget {
  final Color color;

  const FolderIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.blurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.folder, size: 30, color: Colors.white),
    );
  }
}

class SidebarIcon extends ConsumerStatefulWidget {
  final bool selected;
  final UserGuild guild;
  final bool mini;
  final bool isClickable;

  const SidebarIcon({
    super.key,
    required this.selected,
    required this.guild,
    this.mini = false,
    this.isClickable = true,
  });

  @override
  ConsumerState<SidebarIcon> createState() => _SidebarIconState();
}

class _SidebarIconState extends ConsumerState<SidebarIcon> {
  Future<double> get iconHeight => Future<double>.value(40);

  Widget iconBuilder(UserGuild guild, Image? guildIcon) {
    if (guildIcon != null) {
      return guildIcon;
    } else {
      String iconText = "";
      List<String> words = guild.name.split(" ");
      for (var word in words) {
        if (word.isEmpty) continue;
        iconText += word[0];
      }

      return Container(
        color: Theme.of(context).custom.colorTheme.foreground,
        child: Center(
            child: Text(iconText,
                overflow: TextOverflow.ellipsis,
                style: CustomTextTheme()
                    .titleSmall
                    .copyWith(fontSize: widget.mini ? 8 : 12))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Image? guildIcon =
        ref.watch(guildIconProvider(widget.guild.id)).valueOrNull;
    return SizedBox(
      width: widget.mini ? 25 : 55,
      height: widget.mini ? 25 : 55,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Center(
            child: SizedBox(
              width: widget.mini ? 20 : 47,
              height: widget.mini ? 20 : 47,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: widget.isClickable
                      ? TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          onPressed: () {
                            widget.guild.manager
                                .get(widget.guild.id)
                                .then((Guild guild) async {
                              GoRouter.of(context).go(
                                  '/channels/${widget.guild.id}/${guild.rulesChannelId ?? (await guild.fetchChannels()).first.id.value}');
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                                Radius.circular(widget.selected ? 15 : 100)),
                            child: iconBuilder(widget.guild, guildIcon),
                          ))
                      : ClipRRect(
                          borderRadius: BorderRadius.all(
                              Radius.circular(widget.selected ? 15 : 100)),
                          child: iconBuilder(widget.guild, guildIcon),
                        )),
            ),
          ),
          if (widget.selected && !widget.mini)
            Positioned(
              left: 0,
              child: FutureBuilder<double>(
                future: iconHeight,
                builder: (context, snapshot) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOutExpo,
                    width: 4,
                    height: snapshot.data ?? 8,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                          topRight: Radius.circular(8),
                        )),
                  );
                },
              ),
            )
        ],
      ),
    );
  }
}
