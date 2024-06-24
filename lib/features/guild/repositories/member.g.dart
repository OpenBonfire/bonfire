// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getMemberHash() => r'6813731e4f7b5c563bbf1e9bd018345f616c1029';

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

/// See also [getMember].
@ProviderFor(getMember)
const getMemberProvider = GetMemberFamily();

/// See also [getMember].
class GetMemberFamily extends Family<AsyncValue<Member?>> {
  /// See also [getMember].
  const GetMemberFamily();

  /// See also [getMember].
  GetMemberProvider call(
    Snowflake memberId,
  ) {
    return GetMemberProvider(
      memberId,
    );
  }

  @override
  GetMemberProvider getProviderOverride(
    covariant GetMemberProvider provider,
  ) {
    return call(
      provider.memberId,
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
  String? get name => r'getMemberProvider';
}

/// See also [getMember].
class GetMemberProvider extends AutoDisposeFutureProvider<Member?> {
  /// See also [getMember].
  GetMemberProvider(
    Snowflake memberId,
  ) : this._internal(
          (ref) => getMember(
            ref as GetMemberRef,
            memberId,
          ),
          from: getMemberProvider,
          name: r'getMemberProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getMemberHash,
          dependencies: GetMemberFamily._dependencies,
          allTransitiveDependencies: GetMemberFamily._allTransitiveDependencies,
          memberId: memberId,
        );

  GetMemberProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memberId,
  }) : super.internal();

  final Snowflake memberId;

  @override
  Override overrideWith(
    FutureOr<Member?> Function(GetMemberRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetMemberProvider._internal(
        (ref) => create(ref as GetMemberRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memberId: memberId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Member?> createElement() {
    return _GetMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetMemberProvider && other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetMemberRef on AutoDisposeFutureProviderRef<Member?> {
  /// The parameter `memberId` of this provider.
  Snowflake get memberId;
}

class _GetMemberProviderElement
    extends AutoDisposeFutureProviderElement<Member?> with GetMemberRef {
  _GetMemberProviderElement(super.provider);

  @override
  Snowflake get memberId => (origin as GetMemberProvider).memberId;
}

String _$getGuildRolesHash() => r'9138b8178b3dc01b322c556184e01ce90aef9651';

/// See also [getGuildRoles].
@ProviderFor(getGuildRoles)
final getGuildRolesProvider = AutoDisposeFutureProvider<List<Role>?>.internal(
  getGuildRoles,
  name: r'getGuildRolesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getGuildRolesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetGuildRolesRef = AutoDisposeFutureProviderRef<List<Role>?>;
String _$getRoleHash() => r'4b3024638d3be37bbd1ba85bc109b472db86796a';

/// See also [getRole].
@ProviderFor(getRole)
const getRoleProvider = GetRoleFamily();

/// See also [getRole].
class GetRoleFamily extends Family<AsyncValue<Role>> {
  /// See also [getRole].
  const GetRoleFamily();

  /// See also [getRole].
  GetRoleProvider call(
    Snowflake roleId,
  ) {
    return GetRoleProvider(
      roleId,
    );
  }

  @override
  GetRoleProvider getProviderOverride(
    covariant GetRoleProvider provider,
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
  String? get name => r'getRoleProvider';
}

/// See also [getRole].
class GetRoleProvider extends AutoDisposeFutureProvider<Role> {
  /// See also [getRole].
  GetRoleProvider(
    Snowflake roleId,
  ) : this._internal(
          (ref) => getRole(
            ref as GetRoleRef,
            roleId,
          ),
          from: getRoleProvider,
          name: r'getRoleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getRoleHash,
          dependencies: GetRoleFamily._dependencies,
          allTransitiveDependencies: GetRoleFamily._allTransitiveDependencies,
          roleId: roleId,
        );

  GetRoleProvider._internal(
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
  Override overrideWith(
    FutureOr<Role> Function(GetRoleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetRoleProvider._internal(
        (ref) => create(ref as GetRoleRef),
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
  AutoDisposeFutureProviderElement<Role> createElement() {
    return _GetRoleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetRoleProvider && other.roleId == roleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetRoleRef on AutoDisposeFutureProviderRef<Role> {
  /// The parameter `roleId` of this provider.
  Snowflake get roleId;
}

class _GetRoleProviderElement extends AutoDisposeFutureProviderElement<Role>
    with GetRoleRef {
  _GetRoleProviderElement(super.provider);

  @override
  Snowflake get roleId => (origin as GetRoleProvider).roleId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
