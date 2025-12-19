import 'package:dart_mappable/dart_mappable.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entity_store.mapper.dart';
part 'entity_store.g.dart';

@MappableClass()
class EntityState with EntityStateMappable {
  final Map<Snowflake, Guild> guilds;

  const EntityState({this.guilds = const {}});
}

@Riverpod(keepAlive: true)
class EntityStore extends _$EntityStore {
  @override
  EntityState build() => const EntityState();

  void upsertGuild(Guild guild) {
    state = state.copyWith(guilds: {...state.guilds, guild.id: guild});
  }
}

@riverpod
Guild? guild(Ref ref, Snowflake id) =>
    ref.watch(entityStoreProvider.select((s) => s.guilds[id]));
