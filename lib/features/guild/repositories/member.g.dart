// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getMemberHash() => r'872a632ee1cfc42f846999ae07dd364106002113';

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
    Snowflake guildId,
    Snowflake memberId,
  ) {
    return GetMemberProvider(
      guildId,
      memberId,
    );
  }

  @override
  GetMemberProvider getProviderOverride(
    covariant GetMemberProvider provider,
  ) {
    return call(
      provider.guildId,
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
class GetMemberProvider extends FutureProvider<Member?> {
  /// See also [getMember].
  GetMemberProvider(
    Snowflake guildId,
    Snowflake memberId,
  ) : this._internal(
          (ref) => getMember(
            ref as GetMemberRef,
            guildId,
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
          guildId: guildId,
          memberId: memberId,
        );

  GetMemberProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guildId,
    required this.memberId,
  }) : super.internal();

  final Snowflake guildId;
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
        guildId: guildId,
        memberId: memberId,
      ),
    );
  }

  @override
  FutureProviderElement<Member?> createElement() {
    return _GetMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetMemberProvider &&
        other.guildId == guildId &&
        other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetMemberRef on FutureProviderRef<Member?> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;

  /// The parameter `memberId` of this provider.
  Snowflake get memberId;
}

class _GetMemberProviderElement extends FutureProviderElement<Member?>
    with GetMemberRef {
  _GetMemberProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as GetMemberProvider).guildId;
  @override
  Snowflake get memberId => (origin as GetMemberProvider).memberId;
}

String _$getSelfMemberHash() => r'387044745401e1670ea0a43dcfd1d829bdcddbb4';

/// See also [getSelfMember].
@ProviderFor(getSelfMember)
const getSelfMemberProvider = GetSelfMemberFamily();

/// See also [getSelfMember].
class GetSelfMemberFamily extends Family<AsyncValue<Member?>> {
  /// See also [getSelfMember].
  const GetSelfMemberFamily();

  /// See also [getSelfMember].
  GetSelfMemberProvider call(
    Snowflake guildId,
  ) {
    return GetSelfMemberProvider(
      guildId,
    );
  }

  @override
  GetSelfMemberProvider getProviderOverride(
    covariant GetSelfMemberProvider provider,
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
  String? get name => r'getSelfMemberProvider';
}

/// See also [getSelfMember].
class GetSelfMemberProvider extends FutureProvider<Member?> {
  /// See also [getSelfMember].
  GetSelfMemberProvider(
    Snowflake guildId,
  ) : this._internal(
          (ref) => getSelfMember(
            ref as GetSelfMemberRef,
            guildId,
          ),
          from: getSelfMemberProvider,
          name: r'getSelfMemberProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getSelfMemberHash,
          dependencies: GetSelfMemberFamily._dependencies,
          allTransitiveDependencies:
              GetSelfMemberFamily._allTransitiveDependencies,
          guildId: guildId,
        );

  GetSelfMemberProvider._internal(
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
  Override overrideWith(
    FutureOr<Member?> Function(GetSelfMemberRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetSelfMemberProvider._internal(
        (ref) => create(ref as GetSelfMemberRef),
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
  FutureProviderElement<Member?> createElement() {
    return _GetSelfMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetSelfMemberProvider && other.guildId == guildId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetSelfMemberRef on FutureProviderRef<Member?> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;
}

class _GetSelfMemberProviderElement extends FutureProviderElement<Member?>
    with GetSelfMemberRef {
  _GetSelfMemberProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as GetSelfMemberProvider).guildId;
}

String _$getGuildRolesHash() => r'02f52758380d342befe92d584d3d78f250552951';

/// See also [getGuildRoles].
@ProviderFor(getGuildRoles)
const getGuildRolesProvider = GetGuildRolesFamily();

/// See also [getGuildRoles].
class GetGuildRolesFamily extends Family<AsyncValue<List<Role>?>> {
  /// See also [getGuildRoles].
  const GetGuildRolesFamily();

  /// See also [getGuildRoles].
  GetGuildRolesProvider call(
    Snowflake guildId,
  ) {
    return GetGuildRolesProvider(
      guildId,
    );
  }

  @override
  GetGuildRolesProvider getProviderOverride(
    covariant GetGuildRolesProvider provider,
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
  String? get name => r'getGuildRolesProvider';
}

/// See also [getGuildRoles].
class GetGuildRolesProvider extends AutoDisposeFutureProvider<List<Role>?> {
  /// See also [getGuildRoles].
  GetGuildRolesProvider(
    Snowflake guildId,
  ) : this._internal(
          (ref) => getGuildRoles(
            ref as GetGuildRolesRef,
            guildId,
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
          guildId: guildId,
        );

  GetGuildRolesProvider._internal(
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
        guildId: guildId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Role>?> createElement() {
    return _GetGuildRolesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetGuildRolesProvider && other.guildId == guildId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetGuildRolesRef on AutoDisposeFutureProviderRef<List<Role>?> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;
}

class _GetGuildRolesProviderElement
    extends AutoDisposeFutureProviderElement<List<Role>?>
    with GetGuildRolesRef {
  _GetGuildRolesProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as GetGuildRolesProvider).guildId;
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
