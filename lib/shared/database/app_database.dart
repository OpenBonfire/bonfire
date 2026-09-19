import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:firebridge/firebridge.dart';

part 'app_database.g.dart';

/// Persisted guilds, keyed by id. The full entity is stored as JSON since it
/// has dozens of fields we don't need to query on individually - only [id]
/// needs to be a real column so we can look guilds up and list them.
@DataClassName('GuildRow')
class Guilds extends Table {
  IntColumn get id => integer()();
  TextColumn get data => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Persisted channels, keyed by id. [guildId] is pulled out of the JSON blob
/// into its own column so we can query "all channels in this guild" without
/// decoding every row.
@DataClassName('ChannelRow')
class Channels extends Table {
  IntColumn get id => integer()();
  IntColumn get guildId => integer().nullable()();
  TextColumn get data => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Small, singleton-ish values (e.g. the user's guild folder layout) that
/// don't warrant their own table.
class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

const _guildFoldersKey = 'guildFolders';

@DriftDatabase(tables: [Guilds, Channels, KeyValues])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'bonfire'));

  @override
  int get schemaVersion => 1;

  // --- Guilds ---

  Future<void> upsertGuild(Guild guild) {
    return into(guilds).insertOnConflictUpdate(
      GuildsCompanion.insert(
        id: Value(guild.id.value),
        data: jsonEncode(guild.toMap()),
      ),
    );
  }

  Stream<Guild?> watchGuild(Snowflake id) {
    return (select(guilds)..where((t) => t.id.equals(id.value)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : GuildMapper.fromMap(jsonDecode(row.data)));
  }

  Stream<List<Snowflake>> watchGuildIds() {
    return (select(guilds)..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .watch()
        .map((rows) => rows.map((r) => Snowflake(r.id)).toList());
  }

  // --- Channels ---

  Future<void> upsertChannel(Channel channel) {
    return into(channels).insertOnConflictUpdate(_channelCompanion(channel));
  }

  Future<void> upsertGuildChannels(Snowflake guildId, List<Channel> channelList) {
    return batch((b) {
      b.insertAllOnConflictUpdate(
        channels,
        channelList.map(_channelCompanion),
      );
    });
  }

  ChannelsCompanion _channelCompanion(Channel channel) {
    return ChannelsCompanion.insert(
      id: Value(channel.id.value),
      guildId: Value(channel is GuildChannel ? channel.guildId.value : null),
      data: jsonEncode(channel.toMap()),
    );
  }

  Stream<Channel?> watchChannel(Snowflake id) {
    return (select(channels)..where((t) => t.id.equals(id.value)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : ChannelMapper.fromMap(jsonDecode(row.data)));
  }

  Stream<List<Channel>> watchGuildChannels(Snowflake guildId) {
    return (select(channels)..where((t) => t.guildId.equals(guildId.value)))
        .watch()
        .map((rows) => rows.map((r) => ChannelMapper.fromMap(jsonDecode(r.data))).toList());
  }

  // --- Guild folders ---

  Future<void> upsertGuildFolders(List<GuildFolder> folders) {
    return into(keyValues).insertOnConflictUpdate(
      KeyValuesCompanion.insert(
        key: _guildFoldersKey,
        value: jsonEncode(folders.map((f) => f.toMap()).toList()),
      ),
    );
  }

  Stream<List<GuildFolder>> watchGuildFolders() {
    return (select(keyValues)..where((t) => t.key.equals(_guildFoldersKey)))
        .watchSingleOrNull()
        .map((row) {
      if (row == null) return const <GuildFolder>[];
      final raw = jsonDecode(row.value) as List;
      return raw
          .map((m) => GuildFolderMapper.fromMap(m as Map<String, dynamic>))
          .toList();
    });
  }
}
