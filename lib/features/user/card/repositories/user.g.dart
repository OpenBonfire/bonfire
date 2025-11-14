// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getUserFromIdHash() => r'b9f710953c3cadec6e35fdda3d2edd185e7d4f5a';

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

/// Get user by id
///
/// Copied from [getUserFromId].
@ProviderFor(getUserFromId)
const getUserFromIdProvider = GetUserFromIdFamily();

/// Get user by id
///
/// Copied from [getUserFromId].
class GetUserFromIdFamily extends Family<AsyncValue<User?>> {
  /// Get user by id
  ///
  /// Copied from [getUserFromId].
  const GetUserFromIdFamily();

  /// Get user by id
  ///
  /// Copied from [getUserFromId].
  GetUserFromIdProvider call(
    Snowflake userId,
  ) {
    return GetUserFromIdProvider(
      userId,
    );
  }

  @override
  GetUserFromIdProvider getProviderOverride(
    covariant GetUserFromIdProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'getUserFromIdProvider';
}

/// Get user by id
///
/// Copied from [getUserFromId].
class GetUserFromIdProvider extends AutoDisposeFutureProvider<User?> {
  /// Get user by id
  ///
  /// Copied from [getUserFromId].
  GetUserFromIdProvider(
    Snowflake userId,
  ) : this._internal(
          (ref) => getUserFromId(
            ref as GetUserFromIdRef,
            userId,
          ),
          from: getUserFromIdProvider,
          name: r'getUserFromIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getUserFromIdHash,
          dependencies: GetUserFromIdFamily._dependencies,
          allTransitiveDependencies:
              GetUserFromIdFamily._allTransitiveDependencies,
          userId: userId,
        );

  GetUserFromIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final Snowflake userId;

  @override
  Override overrideWith(
    FutureOr<User?> Function(GetUserFromIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetUserFromIdProvider._internal(
        (ref) => create(ref as GetUserFromIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<User?> createElement() {
    return _GetUserFromIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetUserFromIdProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetUserFromIdRef on AutoDisposeFutureProviderRef<User?> {
  /// The parameter `userId` of this provider.
  Snowflake get userId;
}

class _GetUserFromIdProviderElement
    extends AutoDisposeFutureProviderElement<User?> with GetUserFromIdRef {
  _GetUserFromIdProviderElement(super.provider);

  @override
  Snowflake get userId => (origin as GetUserFromIdProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
