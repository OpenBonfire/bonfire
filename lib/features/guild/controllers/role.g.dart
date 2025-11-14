// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roleControllerHash() => r'b0278c3a95ca2575c14b52ffb212ab10504ec7c7';

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

abstract class _$RoleController extends BuildlessNotifier<Role?> {
  late final Snowflake roleId;

  Role? build(
    Snowflake roleId,
  );
}

/// Gets the role from [roleId].
///
/// Copied from [RoleController].
@ProviderFor(RoleController)
const roleControllerProvider = RoleControllerFamily();

/// Gets the role from [roleId].
///
/// Copied from [RoleController].
class RoleControllerFamily extends Family<Role?> {
  /// Gets the role from [roleId].
  ///
  /// Copied from [RoleController].
  const RoleControllerFamily();

  /// Gets the role from [roleId].
  ///
  /// Copied from [RoleController].
  RoleControllerProvider call(
    Snowflake roleId,
  ) {
    return RoleControllerProvider(
      roleId,
    );
  }

  @override
  RoleControllerProvider getProviderOverride(
    covariant RoleControllerProvider provider,
  ) {
    return call(
      provider.roleId,
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
  String? get name => r'roleControllerProvider';
}

/// Gets the role from [roleId].
///
/// Copied from [RoleController].
class RoleControllerProvider
    extends NotifierProviderImpl<RoleController, Role?> {
  /// Gets the role from [roleId].
  ///
  /// Copied from [RoleController].
  RoleControllerProvider(
    Snowflake roleId,
  ) : this._internal(
          () => RoleController()..roleId = roleId,
          from: roleControllerProvider,
          name: r'roleControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roleControllerHash,
          dependencies: RoleControllerFamily._dependencies,
          allTransitiveDependencies:
              RoleControllerFamily._allTransitiveDependencies,
          roleId: roleId,
        );

  RoleControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roleId,
  }) : super.internal();

  final Snowflake roleId;

  @override
  Role? runNotifierBuild(
    covariant RoleController notifier,
  ) {
    return notifier.build(
      roleId,
    );
  }

  @override
  Override overrideWith(RoleController Function() create) {
    return ProviderOverride(
      origin: this,
      override: RoleControllerProvider._internal(
        () => create()..roleId = roleId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roleId: roleId,
      ),
    );
  }

  @override
  NotifierProviderElement<RoleController, Role?> createElement() {
    return _RoleControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoleControllerProvider && other.roleId == roleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoleControllerRef on NotifierProviderRef<Role?> {
  /// The parameter `roleId` of this provider.
  Snowflake get roleId;
}

class _RoleControllerProviderElement
    extends NotifierProviderElement<RoleController, Role?>
    with RoleControllerRef {
  _RoleControllerProviderElement(super.provider);

  @override
  Snowflake get roleId => (origin as RoleControllerProvider).roleId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
