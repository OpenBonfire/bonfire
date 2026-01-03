import 'package:dart_mappable/dart_mappable.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entity_store.mapper.dart';
part 'entity_store.g.dart';

@MappableClass()
class EntityState with EntityStateMappable {
  final Map<Snowflake, Guild> guilds;
  final Map<Snowflake, List<Channel>> guildChannels;

  final List<Snowflake> guildIds;
  final List<GuildFolder> guildFolders;

  const EntityState({
    this.guilds = const {},
    this.guildChannels = const {},
    this.guildIds = const [],
    this.guildFolders = const [],
  });
}

@Riverpod(keepAlive: true)
class EntityStore extends _$EntityStore {
  @override
  EntityState build() => const EntityState();

  void upsertGuild(Guild guild) {
    final isNew = !state.guilds.containsKey(guild.id);

    state = state.copyWith(
      guilds: {...state.guilds, guild.id: guild},
      guildIds: isNew ? [...state.guildIds, guild.id] : state.guildIds,
    );
  }

  void removeGuild(Snowflake id) {
    final newGuilds = Map<Snowflake, Guild>.from(state.guilds)..remove(id);
    state = state.copyWith(
      guilds: newGuilds,
      guildIds: state.guildIds.where((guildId) => guildId != id).toList(),
    );
  }

  void upsertGuildFolders(List<GuildFolder> guildFolders) {
    state = state.copyWith(guildFolders: guildFolders);
  }

  void upsertGuildChannels(Ref ref, Snowflake guildId, List<Channel> channels) {
    state = state.copyWith(
      guildChannels: {...state.guildChannels, guildId: channels},
    );
  }
}

@riverpod
List<Snowflake> guildIds(Ref ref) =>
    ref.watch(entityStoreProvider.select((s) => s.guildIds));

@riverpod
Guild? guild(Ref ref, Snowflake id) =>
    ref.watch(entityStoreProvider.select((s) => s.guilds[id]));

@riverpod
List<GuildFolder> guildFolders(Ref ref) =>
    ref.watch(entityStoreProvider.select((s) => s.guildFolders));

@riverpod
List<Channel>? guildChannels(Ref ref, Snowflake id) =>
    ref.watch(entityStoreProvider.select((s) => s.guildChannels[id]));
