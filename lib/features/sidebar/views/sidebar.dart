import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/features/sidebar/components/guild_folder.dart';
import 'package:bonfire/features/sidebar/components/messages_icon.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebridge/firebridge.dart';
import 'package:bonfire/shared/utils/platform.dart';
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

    double bottomPadding = MediaQuery.of(context).padding.bottom;
    double navbarHeight = shouldUseMobileLayout(context) ? 40 : 0;

    List<UserGuild> guildList = [];
    guildWatch.when(
        data: (guilds) {
          guildList = guilds;
        },
        error: (data, trace) {
          print("ERROR11111111111");
        },
        loading: () {});

    List<GuildFolder>? guildFolders = guildFoldersWatch;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).custom.colorTheme.foreground,
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
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: MessagesIcon(
                            selected: widget.guildId == Snowflake.zero,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Container(
                            height: 2,
                            color:
                                Theme.of(context).custom.colorTheme.foreground,
                          ),
                        ),
                        if (guildFolders != null)
                          ...guildFolders.map((folder) => GuildFolderWidget(
                                guildFolder: folder,
                                guildList: guildList,
                                selectedGuildId: widget.guildId,
                              )),
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
