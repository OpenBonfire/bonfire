// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guildControllerHash() => r'2c17663c8ff0b3e36792c1110090eb57113dfaa1';

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

abstract class _$GuildController
    extends BuildlessAutoDisposeAsyncNotifier<Guild?> {
  late final dynamic guildId;

  FutureOr<Guild?> build(
    dynamic guildId,
  );
}

/// Fetches the current guild from [guildid].
///
/// Copied from [GuildController].
@ProviderFor(GuildController)
const guildControllerProvider = GuildControllerFamily();

/// Fetches the current guild from [guildid].
///
/// Copied from [GuildController].
class GuildControllerFamily extends Family<AsyncValue<Guild?>> {
  /// Fetches the current guild from [guildid].
  ///
  /// Copied from [GuildController].
  const GuildControllerFamily();

  /// Fetches the current guild from [guildid].
  ///
  /// Copied from [GuildController].
  GuildControllerProvider call(
    dynamic guildId,
  ) {
    return GuildControllerProvider(
      guildId,
    );
  }

  @override
  GuildControllerProvider getProviderOverride(
    covariant GuildControllerProvider provider,
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
  String? get name => r'guildControllerProvider';
}

/// Fetches the current guild from [guildid].
///
/// Copied from [GuildController].
class GuildControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<GuildController, Guild?> {
  /// Fetches the current guild from [guildid].
  ///
  /// Copied from [GuildController].
  GuildControllerProvider(
    dynamic guildId,
  ) : this._internal(
          () => GuildController()..guildId = guildId,
          from: guildControllerProvider,
          name: r'guildControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$guildControllerHash,
          dependencies: GuildControllerFamily._dependencies,
          allTransitiveDependencies:
              GuildControllerFamily._allTransitiveDependencies,
          guildId: guildId,
        );

  GuildControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guildId,
  }) : super.internal();

  final dynamic guildId;

  @override
  FutureOr<Guild?> runNotifierBuild(
    covariant GuildController notifier,
  ) {
    return notifier.build(
      guildId,
    );
  }

  @override
  Override overrideWith(GuildController Function() create) {
    return ProviderOverride(
      origin: this,
      override: GuildControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<GuildController, Guild?>
      createElement() {
    return _GuildControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GuildControllerProvider && other.guildId == guildId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GuildControllerRef on AutoDisposeAsyncNotifierProviderRef<Guild?> {
  /// The parameter `guildId` of this provider.
  dynamic get guildId;
}

class _GuildControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<GuildController, Guild?>
    with GuildControllerRef {
  _GuildControllerProviderElement(super.provider);

  @override
  dynamic get guildId => (origin as GuildControllerProvider).guildId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
