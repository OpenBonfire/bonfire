// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_avatar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userAvatarHash() => r'5933e860ee8d736b2d5e707a0a3bcd5e2a0b1fd2';

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

/// See also [userAvatar].
@ProviderFor(userAvatar)
const userAvatarProvider = UserAvatarFamily();

/// See also [userAvatar].
class UserAvatarFamily extends Family<AsyncValue<Uint8List?>> {
  /// See also [userAvatar].
  const UserAvatarFamily();

  /// See also [userAvatar].
  UserAvatarProvider call(
    User user,
  ) {
    return UserAvatarProvider(
      user,
    );
  }

  @override
  UserAvatarProvider getProviderOverride(
    covariant UserAvatarProvider provider,
  ) {
    return call(
      provider.user,
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
  String? get name => r'userAvatarProvider';
}

/// See also [userAvatar].
class UserAvatarProvider extends AutoDisposeFutureProvider<Uint8List?> {
  /// See also [userAvatar].
  UserAvatarProvider(
    User user,
  ) : this._internal(
          (ref) => userAvatar(
            ref as UserAvatarRef,
            user,
          ),
          from: userAvatarProvider,
          name: r'userAvatarProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userAvatarHash,
          dependencies: UserAvatarFamily._dependencies,
          allTransitiveDependencies:
              UserAvatarFamily._allTransitiveDependencies,
          user: user,
        );

  UserAvatarProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.user,
  }) : super.internal();

  final User user;

  @override
  Override overrideWith(
    FutureOr<Uint8List?> Function(UserAvatarRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserAvatarProvider._internal(
        (ref) => create(ref as UserAvatarRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        user: user,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Uint8List?> createElement() {
    return _UserAvatarProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserAvatarProvider && other.user == user;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, user.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserAvatarRef on AutoDisposeFutureProviderRef<Uint8List?> {
  /// The parameter `user` of this provider.
  User get user;
}

class _UserAvatarProviderElement
    extends AutoDisposeFutureProviderElement<Uint8List?> with UserAvatarRef {
  _UserAvatarProviderElement(super.provider);

  @override
  User get user => (origin as UserAvatarProvider).user;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
