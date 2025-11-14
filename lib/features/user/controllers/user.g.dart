// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userControllerHash() => r'ed579518bea5be24ee9459a8ff7e8d1b70894c31';

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

abstract class _$UserController extends BuildlessNotifier<User?> {
  late final Snowflake userId;

  User? build(
    Snowflake userId,
  );
}

/// See also [UserController].
@ProviderFor(UserController)
const userControllerProvider = UserControllerFamily();

/// See also [UserController].
class UserControllerFamily extends Family<User?> {
  /// See also [UserController].
  const UserControllerFamily();

  /// See also [UserController].
  UserControllerProvider call(
    Snowflake userId,
  ) {
    return UserControllerProvider(
      userId,
    );
  }

  @override
  UserControllerProvider getProviderOverride(
    covariant UserControllerProvider provider,
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
  String? get name => r'userControllerProvider';
}

/// See also [UserController].
class UserControllerProvider
    extends NotifierProviderImpl<UserController, User?> {
  /// See also [UserController].
  UserControllerProvider(
    Snowflake userId,
  ) : this._internal(
          () => UserController()..userId = userId,
          from: userControllerProvider,
          name: r'userControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userControllerHash,
          dependencies: UserControllerFamily._dependencies,
          allTransitiveDependencies:
              UserControllerFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserControllerProvider._internal(
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
  User? runNotifierBuild(
    covariant UserController notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(UserController Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserControllerProvider._internal(
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
  NotifierProviderElement<UserController, User?> createElement() {
    return _UserControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserControllerProvider && other.userId == userId;
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
mixin UserControllerRef on NotifierProviderRef<User?> {
  /// The parameter `userId` of this provider.
  Snowflake get userId;
}

class _UserControllerProviderElement
    extends NotifierProviderElement<UserController, User?>
    with UserControllerRef {
  _UserControllerProviderElement(super.provider);

  @override
  Snowflake get userId => (origin as UserControllerProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
