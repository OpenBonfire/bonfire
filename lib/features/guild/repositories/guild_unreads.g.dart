// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_unreads.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guildUnreadsHash() => r'6d630b6e5879908723a30b590de29e523100a206';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$GuildUnreads extends BuildlessAsyncNotifier<bool> {
  late final Snowflake guildId;

  FutureOr<bool> build(
    Snowflake guildId,
  );
}

/// See also [GuildUnreads].
@ProviderFor(GuildUnreads)
const guildUnreadsProvider = GuildUnreadsFamily();

/// See also [GuildUnreads].
class GuildUnreadsFamily extends Family<AsyncValue<bool>> {
  /// See also [GuildUnreads].
  const GuildUnreadsFamily();

  /// See also [GuildUnreads].
  GuildUnreadsProvider call(
    Snowflake guildId,
  ) {
    return GuildUnreadsProvider(
      guildId,
    );
  }

  @override
  GuildUnreadsProvider getProviderOverride(
    covariant GuildUnreadsProvider provider,
  ) {
    return call(
      provider.guildId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'guildUnreadsProvider';
}

/// See also [GuildUnreads].
class GuildUnreadsProvider
    extends AsyncNotifierProviderImpl<GuildUnreads, bool> {
  /// See also [GuildUnreads].
  GuildUnreadsProvider(
    Snowflake guildId,
  ) : this._internal(
          () => GuildUnreads()..guildId = guildId,
          from: guildUnreadsProvider,
          name: r'guildUnreadsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$guildUnreadsHash,
          dependencies: GuildUnreadsFamily._dependencies,
          allTransitiveDependencies:
              GuildUnreadsFamily._allTransitiveDependencies,
          guildId: guildId,
        );

  GuildUnreadsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guildId,
  }) : super.internal();

  final Snowflake guildId;

  @override
  FutureOr<bool> runNotifierBuild(
    covariant GuildUnreads notifier,
  ) {
    return notifier.build(
      guildId,
    );
  }

  @override
  Override overrideWith(GuildUnreads Function() create) {
    return ProviderOverride(
      origin: this,
      override: GuildUnreadsProvider._internal(
        () => create()..guildId = guildId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guildId: guildId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<GuildUnreads, bool> createElement() {
    return _GuildUnreadsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GuildUnreadsProvider && other.guildId == guildId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GuildUnreadsRef on AsyncNotifierProviderRef<bool> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;
}

class _GuildUnreadsProviderElement
    extends AsyncNotifierProviderElement<GuildUnreads, bool>
    with GuildUnreadsRef {
  _GuildUnreadsProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as GuildUnreadsProvider).guildId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
