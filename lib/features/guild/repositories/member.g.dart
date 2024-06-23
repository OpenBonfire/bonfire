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

String _$getGuildRolesHash() => r'f26f92c1cb3af1d7308a92aada06ba72777c0113';

/// See also [getGuildRoles].
@ProviderFor(getGuildRoles)
final getGuildRolesProvider = AutoDisposeFutureProvider<List<Role?>?>.internal(
  getGuildRoles,
  name: r'getGuildRolesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getGuildRolesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetGuildRolesRef = AutoDisposeFutureProviderRef<List<Role?>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
