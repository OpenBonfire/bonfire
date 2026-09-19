import 'package:bonfire/features/guilds/components/sidebar/folder.dart';
import 'package:bonfire/features/guilds/components/sidebar/guild_item.dart';
import 'package:bonfire/features/guilds/components/sidebar/sidebar_entries.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuildSidebar extends ConsumerStatefulWidget {
  const GuildSidebar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GuildSidebarState();
}

class _GuildSidebarState extends ConsumerState<GuildSidebar> {
  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(guildSidebarEntriesProvider);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: CustomScrollView(
        slivers: [
          SliverList.separated(
            itemCount: entries.length,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) => switch (entries[index]) {
              GuildSidebarGuildEntry(:final guildId) => GuildSidebarItem(
                guildId: guildId,
              ),
              GuildSidebarFolderEntry(:final folder) => GuildFolderItem(
                folder: folder,
              ),
            },
          ),
        ],
      ),
    );
  }
}
