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

@DataClassName('ReadStateRow')
class ReadStates extends Table {
  IntColumn get channelId => integer()();
  IntColumn get lastMessageId => integer().nullable()();
  IntColumn get mentionCount => integer().nullable()();

  @override
  Set<Column> get primaryKey => {channelId};
}

/// Persisted users, keyed by id. Same JSON-blob shape as [Guilds]/[Channels].
@DataClassName('UserRow')
class Users extends Table {
  IntColumn get id => integer()();
  TextColumn get data => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Who is currently in which voice channel. A user can only be connected to
/// one voice channel at a time, so [userId] alone is the primary key - a row
/// existing at all means that user is in a voice channel somewhere.
@DataClassName('VoiceStateRow')
class VoiceStates extends Table {
  IntColumn get userId => integer()();
  IntColumn get guildId => integer()();
  IntColumn get channelId => integer()();

  @override
  Set<Column> get primaryKey => {userId};
}

const _guildFoldersKey = 'guildFolders';

@DriftDatabase(tables: [Guilds, Channels, KeyValues, ReadStates, Users, VoiceStates])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'bonfire'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(readStates);
      }
      if (from < 3) {
        await m.createTable(users);
        await m.createTable(voiceStates);
      }
    },
  );

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
    return (select(
      guilds,
    )..where((t) => t.id.equals(id.value))).watchSingleOrNull().map(
      (row) => row == null ? null : GuildMapper.fromMap(jsonDecode(row.data)),
    );
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

  Future<void> upsertGuildChannels(
    Snowflake guildId,
    List<Channel> channelList,
  ) {
    return batch((b) {
      b.insertAllOnConflictUpdate(channels, channelList.map(_channelCompanion));
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
    return (select(
      channels,
    )..where((t) => t.id.equals(id.value))).watchSingleOrNull().map(
      (row) => row == null ? null : ChannelMapper.fromMap(jsonDecode(row.data)),
    );
  }

  Stream<List<Channel>> watchGuildChannels(Snowflake guildId) {
    return (select(
      channels,
    )..where((t) => t.guildId.equals(guildId.value))).watch().map(
      (rows) =>
          rows.map((r) => ChannelMapper.fromMap(jsonDecode(r.data))).toList(),
    );
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

  // --- Read states ---

  Future<void> upsertReadState(ReadState readState) {
    return into(readStates).insertOnConflictUpdate(
      ReadStatesCompanion.insert(
        channelId: Value(readState.channelId.value),
        lastMessageId: Value(readState.lastMessageId?.value),
        mentionCount: Value(readState.mentionCount),
      ),
    );
  }

  Stream<int?> watchLastReadMessageId(Snowflake channelId) {
    return (select(readStates)
          ..where((t) => t.channelId.equals(channelId.value)))
        .watchSingleOrNull()
        .map((row) => row?.lastMessageId);
  }

  // --- Users ---

  Future<void> upsertUser(User user) {
    return into(users).insertOnConflictUpdate(
      UsersCompanion.insert(
        id: Value(user.id.value),
        data: jsonEncode(user.toMap()),
      ),
    );
  }

  Stream<User?> watchUser(Snowflake id) {
    return (select(
      users,
    )..where((t) => t.id.equals(id.value))).watchSingleOrNull().map(
      (row) => row == null ? null : UserMapper.fromMap(jsonDecode(row.data)),
    );
  }

  // --- Voice states ---

  /// A `channelId`/`guildId` of `null` means the user left voice entirely -
  /// there's nothing useful to store, so the row is removed instead.
  Future<void> upsertVoiceState(VoiceState voiceState) {
    final guildId = voiceState.guildId;
    final channelId = voiceState.channelId;
    if (guildId == null || channelId == null) {
      return deleteVoiceState(voiceState.userId);
    }

    return into(voiceStates).insertOnConflictUpdate(
      VoiceStatesCompanion.insert(
        userId: Value(voiceState.userId.value),
        guildId: guildId.value,
        channelId: channelId.value,
      ),
    );
  }

  Future<void> deleteVoiceState(Snowflake userId) {
    return (delete(
      voiceStates,
    )..where((t) => t.userId.equals(userId.value))).go();
  }

  Stream<List<Snowflake>> watchChannelVoiceStateUserIds(Snowflake channelId) {
    return (select(voiceStates)
          ..where((t) => t.channelId.equals(channelId.value)))
        .watch()
        .map((rows) => rows.map((r) => Snowflake(r.userId)).toList());
  }
}
