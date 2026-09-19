import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sidebar_entries.g.dart';

/// A single row in the guild sidebar: either a standalone guild or a folder.
sealed class GuildSidebarEntry {
  const GuildSidebarEntry();
}

class GuildSidebarGuildEntry extends GuildSidebarEntry {
  final Snowflake guildId;
  const GuildSidebarGuildEntry(this.guildId);
}

class GuildSidebarFolderEntry extends GuildSidebarEntry {
  final GuildFolder folder;
  const GuildSidebarFolderEntry(this.folder);
}

/// The ordered, deduplicated list of sidebar rows: guilds in a folder are
/// collapsed into a single [GuildSidebarFolderEntry] (at the position of the
/// first of their guilds), every other guild becomes its own
/// [GuildSidebarGuildEntry], all in [guildIdsProvider] order.
@riverpod
List<GuildSidebarEntry> guildSidebarEntries(Ref ref) {
  final guildIds = ref.watch(guildIdsProvider);
  final folders = ref.watch(guildFoldersProvider);

  final folderByGuildId = <Snowflake, GuildFolder>{
    for (final folder in folders)
      for (final guildId in folder.guildIds) guildId: folder,
  };

  final entries = <GuildSidebarEntry>[];
  final renderedFolderIds = <int>{};
  for (final guildId in guildIds) {
    final folder = folderByGuildId[guildId];
    if (folder == null) {
      entries.add(GuildSidebarGuildEntry(guildId));
    } else if (renderedFolderIds.add(folder.id!)) {
      entries.add(GuildSidebarFolderEntry(folder));
    }
  }
  return entries;
}
