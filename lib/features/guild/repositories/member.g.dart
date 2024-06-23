// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchMemberHash() => r'b62d7d8745b1f29c45f843f22255d81d49952e17';

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

/// See also [fetchMember].
@ProviderFor(fetchMember)
const fetchMemberProvider = FetchMemberFamily();

/// See also [fetchMember].
class FetchMemberFamily extends Family<AsyncValue<Member?>> {
  /// See also [fetchMember].
  const FetchMemberFamily();

  /// See also [fetchMember].
  FetchMemberProvider call(
    Snowflake memberId,
  ) {
    return FetchMemberProvider(
      memberId,
    );
  }

  @override
  FetchMemberProvider getProviderOverride(
    covariant FetchMemberProvider provider,
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
  String? get name => r'fetchMemberProvider';
}

/// See also [fetchMember].
class FetchMemberProvider extends AutoDisposeFutureProvider<Member?> {
  /// See also [fetchMember].
  FetchMemberProvider(
    Snowflake memberId,
  ) : this._internal(
          (ref) => fetchMember(
            ref as FetchMemberRef,
            memberId,
          ),
          from: fetchMemberProvider,
          name: r'fetchMemberProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchMemberHash,
          dependencies: FetchMemberFamily._dependencies,
          allTransitiveDependencies:
              FetchMemberFamily._allTransitiveDependencies,
          memberId: memberId,
        );

  FetchMemberProvider._internal(
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
    FutureOr<Member?> Function(FetchMemberRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchMemberProvider._internal(
        (ref) => create(ref as FetchMemberRef),
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
    return _FetchMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchMemberProvider && other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FetchMemberRef on AutoDisposeFutureProviderRef<Member?> {
  /// The parameter `memberId` of this provider.
  Snowflake get memberId;
}

class _FetchMemberProviderElement
    extends AutoDisposeFutureProviderElement<Member?> with FetchMemberRef {
  _FetchMemberProviderElement(super.provider);

  @override
  Snowflake get memberId => (origin as FetchMemberProvider).memberId;
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
