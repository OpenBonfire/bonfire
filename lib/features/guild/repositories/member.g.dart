// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getMemberHash() => r'7c4b7c23646053723b24fae579473f9f57cea768';

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
    Guild guild,
    Snowflake memberId,
  ) {
    return GetMemberProvider(
      guild,
      memberId,
    );
  }

  @override
  GetMemberProvider getProviderOverride(
    covariant GetMemberProvider provider,
  ) {
    return call(
      provider.guild,
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
    Guild guild,
    Snowflake memberId,
  ) : this._internal(
          (ref) => getMember(
            ref as GetMemberRef,
            guild,
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
          guild: guild,
          memberId: memberId,
        );

  GetMemberProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guild,
    required this.memberId,
  }) : super.internal();

  final Guild guild;
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
        guild: guild,
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
    return other is GetMemberProvider &&
        other.guild == guild &&
        other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guild.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetMemberRef on AutoDisposeFutureProviderRef<Member?> {
  /// The parameter `guild` of this provider.
  Guild get guild;

  /// The parameter `memberId` of this provider.
  Snowflake get memberId;
}

class _GetMemberProviderElement
    extends AutoDisposeFutureProviderElement<Member?> with GetMemberRef {
  _GetMemberProviderElement(super.provider);

  @override
  Guild get guild => (origin as GetMemberProvider).guild;
  @override
  Snowflake get memberId => (origin as GetMemberProvider).memberId;
}

String _$getGuildRolesHash() => r'a39e000952a51c3092a73682e60a28e05941573d';

/// See also [getGuildRoles].
@ProviderFor(getGuildRoles)
const getGuildRolesProvider = GetGuildRolesFamily();

/// See also [getGuildRoles].
class GetGuildRolesFamily extends Family<AsyncValue<List<Role>?>> {
  /// See also [getGuildRoles].
  const GetGuildRolesFamily();

  /// See also [getGuildRoles].
  GetGuildRolesProvider call(
    Guild guild,
  ) {
    return GetGuildRolesProvider(
      guild,
    );
  }

  @override
  GetGuildRolesProvider getProviderOverride(
    covariant GetGuildRolesProvider provider,
  ) {
    return call(
      provider.guild,
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
  String? get name => r'getGuildRolesProvider';
}

/// See also [getGuildRoles].
class GetGuildRolesProvider extends AutoDisposeFutureProvider<List<Role>?> {
  /// See also [getGuildRoles].
  GetGuildRolesProvider(
    Guild guild,
  ) : this._internal(
          (ref) => getGuildRoles(
            ref as GetGuildRolesRef,
            guild,
          ),
          from: getGuildRolesProvider,
          name: r'getGuildRolesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getGuildRolesHash,
          dependencies: GetGuildRolesFamily._dependencies,
          allTransitiveDependencies:
              GetGuildRolesFamily._allTransitiveDependencies,
          guild: guild,
        );

  GetGuildRolesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guild,
  }) : super.internal();

  final Guild guild;

  @override
  Override overrideWith(
    FutureOr<List<Role>?> Function(GetGuildRolesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetGuildRolesProvider._internal(
        (ref) => create(ref as GetGuildRolesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guild: guild,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Role>?> createElement() {
    return _GetGuildRolesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetGuildRolesProvider && other.guild == guild;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guild.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetGuildRolesRef on AutoDisposeFutureProviderRef<List<Role>?> {
  /// The parameter `guild` of this provider.
  Guild get guild;
}

class _GetGuildRolesProviderElement
    extends AutoDisposeFutureProviderElement<List<Role>?>
    with GetGuildRolesRef {
  _GetGuildRolesProviderElement(super.provider);

  @override
  Guild get guild => (origin as GetGuildRolesProvider).guild;
}

String _$getRoleHash() => r'28dd347c073d347d6584ca45169117daa0a7075f';

/// See also [getRole].
@ProviderFor(getRole)
const getRoleProvider = GetRoleFamily();

/// See also [getRole].
class GetRoleFamily extends Family<AsyncValue<Role>> {
  /// See also [getRole].
  const GetRoleFamily();

  /// See also [getRole].
  GetRoleProvider call(
    Guild guild,
    Snowflake roleId,
  ) {
    return GetRoleProvider(
      guild,
      roleId,
    );
  }

  @override
  GetRoleProvider getProviderOverride(
    covariant GetRoleProvider provider,
  ) {
    return call(
      provider.guild,
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
    Guild guild,
    Snowflake roleId,
  ) : this._internal(
          (ref) => getRole(
            ref as GetRoleRef,
            guild,
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
          guild: guild,
          roleId: roleId,
        );

  GetRoleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guild,
    required this.roleId,
  }) : super.internal();

  final Guild guild;
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
        guild: guild,
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
    return other is GetRoleProvider &&
        other.guild == guild &&
        other.roleId == roleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guild.hashCode);
    hash = _SystemHash.combine(hash, roleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetRoleRef on AutoDisposeFutureProviderRef<Role> {
  /// The parameter `guild` of this provider.
  Guild get guild;

  /// The parameter `roleId` of this provider.
  Snowflake get roleId;
}

class _GetRoleProviderElement extends AutoDisposeFutureProviderElement<Role>
    with GetRoleRef {
  _GetRoleProviderElement(super.provider);

  @override
  Guild get guild => (origin as GetRoleProvider).guild;
  @override
  Snowflake get roleId => (origin as GetRoleProvider).roleId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
