import 'package:bonfire/shared/database/database_provider.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entity_store.g.dart';

@riverpod
Stream<List<Snowflake>> _guildIdsStream(Ref ref) =>
    ref.watch(appDatabaseProvider).watchGuildIds();

@riverpod
List<Snowflake> guildIds(Ref ref) =>
    ref.watch(_guildIdsStreamProvider).value ?? const [];

@riverpod
Stream<Guild?> _guildStream(Ref ref, Snowflake id) =>
    ref.watch(appDatabaseProvider).watchGuild(id);

@riverpod
Guild? guild(Ref ref, Snowflake id) =>
    ref.watch(_guildStreamProvider(id)).value;

@riverpod
Stream<List<GuildFolder>> _guildFoldersStream(Ref ref) =>
    ref.watch(appDatabaseProvider).watchGuildFolders();

@riverpod
List<GuildFolder> guildFolders(Ref ref) =>
    (ref.watch(_guildFoldersStreamProvider).value ?? const [])
        .where((folder) => folder.id != null)
        .toList();

@riverpod
Stream<List<Channel>> _guildChannelsStream(Ref ref, Snowflake id) =>
    ref.watch(appDatabaseProvider).watchGuildChannels(id);

@riverpod
List<Channel>? guildChannels(Ref ref, Snowflake id) =>
    ref.watch(_guildChannelsStreamProvider(id)).value;

@riverpod
Stream<Channel?> _channelStream(Ref ref, Snowflake id) =>
    ref.watch(appDatabaseProvider).watchChannel(id);

@riverpod
Channel? channel(Ref ref, Snowflake id) =>
    ref.watch(_channelStreamProvider(id)).value;
