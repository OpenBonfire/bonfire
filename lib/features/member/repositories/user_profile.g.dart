// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userProfileControllerHash() =>
    r'aa8bd1f1b4e0e83da326430f2e6c0223177b2799';

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

abstract class _$UserProfileController
    extends BuildlessAsyncNotifier<UserProfile?> {
  late final Snowflake userId;

  FutureOr<UserProfile?> build(
    Snowflake userId,
  );
}

/// See also [UserProfileController].
@ProviderFor(UserProfileController)
const userProfileControllerProvider = UserProfileControllerFamily();

/// See also [UserProfileController].
class UserProfileControllerFamily extends Family<AsyncValue<UserProfile?>> {
  /// See also [UserProfileController].
  const UserProfileControllerFamily();

  /// See also [UserProfileController].
  UserProfileControllerProvider call(
    Snowflake userId,
  ) {
    return UserProfileControllerProvider(
      userId,
    );
  }

  @override
  UserProfileControllerProvider getProviderOverride(
    covariant UserProfileControllerProvider provider,
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
  String? get name => r'userProfileControllerProvider';
}

/// See also [UserProfileController].
class UserProfileControllerProvider
    extends AsyncNotifierProviderImpl<UserProfileController, UserProfile?> {
  /// See also [UserProfileController].
  UserProfileControllerProvider(
    Snowflake userId,
  ) : this._internal(
          () => UserProfileController()..userId = userId,
          from: userProfileControllerProvider,
          name: r'userProfileControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userProfileControllerHash,
          dependencies: UserProfileControllerFamily._dependencies,
          allTransitiveDependencies:
              UserProfileControllerFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserProfileControllerProvider._internal(
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
  FutureOr<UserProfile?> runNotifierBuild(
    covariant UserProfileController notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(UserProfileController Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserProfileControllerProvider._internal(
        () => create()..userId = userId,
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
  AsyncNotifierProviderElement<UserProfileController, UserProfile?>
      createElement() {
    return _UserProfileControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileControllerProvider && other.userId == userId;
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
mixin UserProfileControllerRef on AsyncNotifierProviderRef<UserProfile?> {
  /// The parameter `userId` of this provider.
  Snowflake get userId;
}

class _UserProfileControllerProviderElement
    extends AsyncNotifierProviderElement<UserProfileController, UserProfile?>
    with UserProfileControllerRef {
  _UserProfileControllerProviderElement(super.provider);

  @override
  Snowflake get userId => (origin as UserProfileControllerProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
