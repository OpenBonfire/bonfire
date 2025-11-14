import 'package:bonfire/features/guild/controllers/guilds.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/features/sidebar/components/dm_icon.dart';
import 'package:bonfire/features/sidebar/components/guild_folder.dart';
import 'package:bonfire/features/sidebar/components/messages_icon.dart';
import 'package:bonfire/features/sidebar/components/sidebar_icon.dart';
import 'package:bonfire/features/sidebar/components/sidebar_item.dart';
import 'package:bonfire/features/sidebar/controllers/unread_dms.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebridge/firebridge.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:go_router/go_router.dart';
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
  double iconSpacing = 6.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Widget> _buildGuildList(
      List<UserGuild> allGuilds, List<GuildFolder>? folders) {
    List<Widget> items = [];

    // set of guild IDs that are in foldersp
    Set<Snowflake> folderedGuildIds = {};
    if (folders != null) {
      for (var folder in folders) {
        folderedGuildIds.addAll(folder.guildIds);
      }
    }

    // guilds that are not in folders
    for (var guild in allGuilds) {
      if (!folderedGuildIds.contains(guild.id)) {
        items.add(
          Padding(
            padding: EdgeInsets.only(bottom: iconSpacing),
            child: SidebarIcon(
              selected: widget.guildId == guild.id,
              guild: guild,
              isClickable: true,
            ),
          ),
        );
      }
    }

    // folders
    if (folders != null) {
      for (var folder in folders) {
        items.add(
          Padding(
            padding: EdgeInsets.only(bottom: iconSpacing),
            child: GuildFolderWidget(
              guildFolder: folder,
              guildList: allGuilds,
              selectedGuildId: widget.guildId,
            ),
          ),
        );
      }
    }

    return items;
  }

  List<Widget> _buildUnreadDmList() {
    List<ReadState>? unreadDms = ref.watch(unreadDmsProvider);
    String? _channelId = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration
        .pathParameters['channelId'];

    Snowflake? channelId;
    if (_channelId != null) {
      channelId = Snowflake.parse(_channelId);
    }

    if (unreadDms == null || unreadDms.isEmpty) {
      return [];
    }

    return unreadDms.map((readState) {
      // TODO: The selected guildId should really be extracted from the route
      return Padding(
          padding: EdgeInsets.only(bottom: iconSpacing),
          child: SidebarItem(
            selected: channelId == readState.channel.id,
            mentions: readState.mentionCount ?? 0,
            onTap: () {
              debugPrint("tapped dm!");
              GoRouter.of(context).go('/channels/@me/${readState.channel.id}');
            },
            child: DmIcon(privateChannelId: readState.channel.id),
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var guildWatch = ref.watch(guildsControllerProvider);
    var guildFoldersWatch = ref.watch(guildFoldersProvider);

    double bottomPadding = MediaQuery.paddingOf(context).bottom;
    double navbarHeight = shouldUseMobileLayout(context) ? 40 : 0;

    List<UserGuild> guildList = guildWatch ?? [];

    List<GuildFolder>? guildFolders = guildFoldersWatch;

    return Container(
      decoration: BoxDecoration(
        color: BonfireThemeExtension.of(context).background,
        border: Border(
          right: BorderSide(
            color: BonfireThemeExtension.of(context).foreground,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: 75,
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
                        if (isSmartwatch(context)) const SizedBox(height: 36),
                        if (UniversalPlatform.isDesktopOrWeb)
                          const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: MessagesIcon(
                            selected: widget.guildId == Snowflake.zero,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._buildUnreadDmList(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Container(
                            height: 2,
                            color: BonfireThemeExtension.of(context).foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._buildGuildList(guildList, guildFolders),
                        SizedBox(height: bottomPadding + navbarHeight)
                      ],
                    ),
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
