// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EntityStore)
const entityStoreProvider = EntityStoreProvider._();

final class EntityStoreProvider
    extends $NotifierProvider<EntityStore, EntityState> {
  const EntityStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entityStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entityStoreHash();

  @$internal
  @override
  EntityStore create() => EntityStore();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntityState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntityState>(value),
    );
  }
}

String _$entityStoreHash() => r'e400551417db909e4465295b473b3f2b981d4c35';

abstract class _$EntityStore extends $Notifier<EntityState> {
  EntityState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<EntityState, EntityState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EntityState, EntityState>,
              EntityState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(guildIds)
const guildIdsProvider = GuildIdsProvider._();

final class GuildIdsProvider
    extends
        $FunctionalProvider<List<Snowflake>, List<Snowflake>, List<Snowflake>>
    with $Provider<List<Snowflake>> {
  const GuildIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guildIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guildIdsHash();

  @$internal
  @override
  $ProviderElement<List<Snowflake>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Snowflake> create(Ref ref) {
    return guildIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Snowflake> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Snowflake>>(value),
    );
  }
}

String _$guildIdsHash() => r'428dd578af2952ea095886586418f4cd8ff9a644';

@ProviderFor(guild)
const guildProvider = GuildFamily._();

final class GuildProvider extends $FunctionalProvider<Guild?, Guild?, Guild?>
    with $Provider<Guild?> {
  const GuildProvider._({
    required GuildFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'guildProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guildHash();

  @override
  String toString() {
    return r'guildProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Guild?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Guild? create(Ref ref) {
    final argument = this.argument as Snowflake;
    return guild(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Guild? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Guild?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GuildProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guildHash() => r'd747f6d9b65f68b7c8051a7ff6e0b37ea674e0ff';

final class GuildFamily extends $Family
    with $FunctionalFamilyOverride<Guild?, Snowflake> {
  const GuildFamily._()
    : super(
        retry: null,
        name: r'guildProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GuildProvider call(Snowflake id) => GuildProvider._(argument: id, from: this);

  @override
  String toString() => r'guildProvider';
}

@ProviderFor(guildFolders)
const guildFoldersProvider = GuildFoldersProvider._();

final class GuildFoldersProvider
    extends
        $FunctionalProvider<
          List<GuildFolder>,
          List<GuildFolder>,
          List<GuildFolder>
        >
    with $Provider<List<GuildFolder>> {
  const GuildFoldersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guildFoldersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guildFoldersHash();

  @$internal
  @override
  $ProviderElement<List<GuildFolder>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<GuildFolder> create(Ref ref) {
    return guildFolders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<GuildFolder> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<GuildFolder>>(value),
    );
  }
}

String _$guildFoldersHash() => r'1546c1753eaade8c787a407b32d479c0cfd7ee55';

@ProviderFor(guildChannels)
const guildChannelsProvider = GuildChannelsFamily._();

final class GuildChannelsProvider
    extends $FunctionalProvider<List<Channel>?, List<Channel>?, List<Channel>?>
    with $Provider<List<Channel>?> {
  const GuildChannelsProvider._({
    required GuildChannelsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'guildChannelsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guildChannelsHash();

  @override
  String toString() {
    return r'guildChannelsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Channel>?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Channel>? create(Ref ref) {
    final argument = this.argument as Snowflake;
    return guildChannels(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Channel>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Channel>?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GuildChannelsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guildChannelsHash() => r'1c9232a054637b6ca1a52381580d3e5f4598af04';

final class GuildChannelsFamily extends $Family
    with $FunctionalFamilyOverride<List<Channel>?, Snowflake> {
  const GuildChannelsFamily._()
    : super(
        retry: null,
        name: r'guildChannelsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GuildChannelsProvider call(Snowflake id) =>
      GuildChannelsProvider._(argument: id, from: this);

  @override
  String toString() => r'guildChannelsProvider';
}
