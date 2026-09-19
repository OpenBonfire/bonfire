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

@riverpod
Stream<int?> _lastReadMessageIdStream(Ref ref, Snowflake channelId) =>
    ref.watch(appDatabaseProvider).watchLastReadMessageId(channelId);

/// Whether [channelId] has messages the user hasn't read yet. `false` for
/// non-text channels (categories, voice, ...) since they have no read state.
@riverpod
bool channelHasUnreads(Ref ref, Snowflake channelId) {
  final channel = ref.watch(channelProvider(channelId));
  if (channel is! TextChannel) return false;

  final lastMessageId = channel.lastMessageId;
  if (lastMessageId == null) return false;

  final lastReadMessageId =
      ref.watch(_lastReadMessageIdStreamProvider(channelId)).value;
  return lastReadMessageId != lastMessageId.value;
}

/// Whether any channel in [guildId] has unread messages.
@riverpod
bool guildHasUnreads(Ref ref, Snowflake guildId) {
  final channels = ref.watch(guildChannelsProvider(guildId)) ?? const [];
  return channels.any((channel) => ref.watch(channelHasUnreadsProvider(channel.id)));
}

/// Whether any guild in [folder] has unread messages.
@riverpod
bool folderHasUnreads(Ref ref, GuildFolder folder) {
  return folder.guildIds.any((guildId) => ref.watch(guildHasUnreadsProvider(guildId)));
}

@riverpod
Stream<User?> _userStream(Ref ref, Snowflake id) =>
    ref.watch(appDatabaseProvider).watchUser(id);

@riverpod
User? user(Ref ref, Snowflake id) => ref.watch(_userStreamProvider(id)).value;

@riverpod
Stream<List<Snowflake>> _channelVoiceStateUserIdsStream(
  Ref ref,
  Snowflake channelId,
) => ref.watch(appDatabaseProvider).watchChannelVoiceStateUserIds(channelId);

/// The ids of the users currently connected to voice channel [channelId].
@riverpod
List<Snowflake> channelVoiceStateUserIds(Ref ref, Snowflake channelId) =>
    ref.watch(_channelVoiceStateUserIdsStreamProvider(channelId)).value ??
    const [];
