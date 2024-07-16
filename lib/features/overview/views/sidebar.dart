import 'package:bonfire/features/overview/repositories/guild_mentions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/features/overview/repositories/guild_unreads.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:universal_platform/universal_platform.dart';

class Sidebar extends ConsumerStatefulWidget {
  final Snowflake guildId;
  const Sidebar({super.key, required this.guildId});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  UserGuild? previousSelectedGuild;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
            child: Center(
              child: MouseRegion(
                onEnter: (_) {
                  if (!_scrollController.hasClients) return;
                  _scrollController.position.context.setIgnorePointer(false);
                },
                onExit: (_) {
                  if (!_scrollController.hasClients) return;
                  _scrollController.position.context.setIgnorePointer(true);
                },
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: MessagesIcon(
                          selected: widget.guildId == Snowflake.zero,
                        ),
                      ),
                      if (guildFolders != null)
                        ...guildFolders.map((folder) => GuildFolderWidget(
                              guildFolder: folder,
                              guildList: guildList,
                              selectedGuildId: widget.guildId,
                            )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        UniversalPlatform.isMobile
            ? SizedBox(
                height: MediaQuery.of(context).padding.bottom + 50,
              )
            : const SizedBox(),
      ],
    );
  }
}

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
  _GuildFolderWidgetState createState() => _GuildFolderWidgetState();
}

class _GuildFolderWidgetState extends ConsumerState<GuildFolderWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  double _iconHeight = 8;

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

    // If there's only one guild in the folder, treat it as a regular server icon
    if (folderGuilds.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
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

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Stack(
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
                      return Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: 1 - _expandAnimation.value,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
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
                                    color: Color(widget.guildFolder.color ??
                                        Theme.of(context)
                                            .custom
                                            .colorTheme
                                            .blurple
                                            .value),
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
                              children: folderGuilds
                                  .map((guild) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        child: Center(
                                          child: SidebarIcon(
                                            selected: widget.selectedGuildId ==
                                                guild.id,
                                            guild: guild,
                                            isClickable: true,
                                          ),
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
              ),
              SizedBox(height: _isExpanded ? 0 : 4),
            ],
          ),
          if (!_isExpanded || hasUnreadsInFolder)
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
      ),
    );
  }
}

class FolderIcon extends StatelessWidget {
  final Color color;

  const FolderIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.blurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.folder, size: 30, color: Colors.white),
    );
  }
}

class MessagesIcon extends StatelessWidget {
  final bool selected;

  const MessagesIcon({super.key, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: SizedBox(
            width: 47,
            height: 47,
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                GoRouter.of(context).go('/channels/@me');
              },
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(selected ? 15 : 100)),
                child: Transform.scale(
                  scale: 0.4,
                  child: SvgPicture.asset(
                    'assets/icons/dms.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (selected)
          Positioned(
            left: 0,
            child: Container(
              width: 4,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
            ),
          )
      ],
    );
  }
}

class SidebarIcon extends ConsumerStatefulWidget {
  final bool selected;
  final UserGuild guild;
  final bool mini;
  final bool isClickable;
  final bool isInFolder;

  const SidebarIcon({
    super.key,
    required this.selected,
    required this.guild,
    this.mini = false,
    this.isClickable = true,
    this.isInFolder = false,
  });

  @override
  ConsumerState<SidebarIcon> createState() => _SidebarIconState();
}

class _SidebarIconState extends ConsumerState<SidebarIcon> {
  double _iconHeight = 40;

  @override
  void initState() {
    super.initState();
    _updateIconHeight();
  }

  @override
  void didUpdateWidget(SidebarIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIconHeight();
  }

  void _updateIconHeight() {
    var hasUnreads =
        ref.read(guildUnreadsProvider(widget.guild.id)).valueOrNull ?? false;
    setState(() {
      if (hasUnreads && !widget.selected) {
        _iconHeight = 8;
      } else {
        _iconHeight = 40;
      }
    });
  }

  Widget iconBuilder(UserGuild guild) {
    if (guild.icon != null) {
      return CachedNetworkImage(
        imageUrl: guild.icon!.url.toString(),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(
          value: downloadProgress.progress,
          color: Theme.of(context).custom.colorTheme.blurple,
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
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
                    .copyWith(fontSize: widget.mini ? 3 : 12))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var hasUnreads =
        ref.watch(guildUnreadsProvider(widget.guild.id)).valueOrNull ?? false;
    var mentions = ref.watch(guildMentionsProvider(widget.guild.id)).value ?? 0;

    _updateIconHeight();

    bool showIndicator = (widget.selected || hasUnreads) && !widget.mini;
    if (widget.isInFolder && !widget.selected) {
      showIndicator = false;
    }

    Widget mentionBubble(int count) {
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
                ))),
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

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: SizedBox(
            width: widget.mini ? 16 : 47,
            height: widget.mini ? 16 : 47,
            child: widget.isClickable
                ? InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.guild.manager
                          .get(widget.guild.id)
                          .then((Guild guild) async {
                        var lastGuildChannels = Hive.box("last-guild-channels");
                        var channelId =
                            lastGuildChannels.get(guild.id.value.toString()) ??
                                guild.rulesChannelId ??
                                (await guild.fetchChannels()).first.id.value;

                        GoRouter.of(context)
                            .go('/channels/${widget.guild.id}/$channelId');
                      });
                    },
                    splashFactory: NoSplash.splashFactory,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(
                              Radius.circular(widget.selected ? 15 : 100)),
                          child: iconBuilder(widget.guild),
                        ),
                        if (mentions > 0 && !widget.mini)
                          Positioned(
                            right: -3,
                            bottom: -3,
                            child: mentionBubble(mentions),
                          ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.all(
                        Radius.circular(widget.selected ? 15 : 100)),
                    child: iconBuilder(widget.guild),
                  ),
          ),
        ),
        if (showIndicator)
          Positioned(
            left: 0,
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
      ],
    );
  }
}
