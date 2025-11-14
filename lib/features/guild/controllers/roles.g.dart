// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rolesControllerHash() => r'0785eb2bff764f0cba882b5a0c8303ae39ea6e07';

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

abstract class _$RolesController extends BuildlessNotifier<List<Snowflake>?> {
  late final Snowflake guildId;

  List<Snowflake>? build(
    Snowflake guildId,
  );
}

/// Fetches the current roles from [guildId].
///
/// Copied from [RolesController].
@ProviderFor(RolesController)
const rolesControllerProvider = RolesControllerFamily();

/// Fetches the current roles from [guildId].
///
/// Copied from [RolesController].
class RolesControllerFamily extends Family<List<Snowflake>?> {
  /// Fetches the current roles from [guildId].
  ///
  /// Copied from [RolesController].
  const RolesControllerFamily();

  /// Fetches the current roles from [guildId].
  ///
  /// Copied from [RolesController].
  RolesControllerProvider call(
    Snowflake guildId,
  ) {
    return RolesControllerProvider(
      guildId,
    );
  }

  @override
  RolesControllerProvider getProviderOverride(
    covariant RolesControllerProvider provider,
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
  String? get name => r'rolesControllerProvider';
}

/// Fetches the current roles from [guildId].
///
/// Copied from [RolesController].
class RolesControllerProvider
    extends NotifierProviderImpl<RolesController, List<Snowflake>?> {
  /// Fetches the current roles from [guildId].
  ///
  /// Copied from [RolesController].
  RolesControllerProvider(
    Snowflake guildId,
  ) : this._internal(
          () => RolesController()..guildId = guildId,
          from: rolesControllerProvider,
          name: r'rolesControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$rolesControllerHash,
          dependencies: RolesControllerFamily._dependencies,
          allTransitiveDependencies:
              RolesControllerFamily._allTransitiveDependencies,
          guildId: guildId,
        );

  RolesControllerProvider._internal(
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
  List<Snowflake>? runNotifierBuild(
    covariant RolesController notifier,
  ) {
    return notifier.build(
      guildId,
    );
  }

  @override
  Override overrideWith(RolesController Function() create) {
    return ProviderOverride(
      origin: this,
      override: RolesControllerProvider._internal(
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
  NotifierProviderElement<RolesController, List<Snowflake>?> createElement() {
    return _RolesControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RolesControllerProvider && other.guildId == guildId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RolesControllerRef on NotifierProviderRef<List<Snowflake>?> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;
}

class _RolesControllerProviderElement
    extends NotifierProviderElement<RolesController, List<Snowflake>?>
    with RolesControllerRef {
  _RolesControllerProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as RolesControllerProvider).guildId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
