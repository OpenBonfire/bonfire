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

String _$entityStoreHash() => r'6ad2c8c3c1749b23db3ab5903144601192b24819';

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
