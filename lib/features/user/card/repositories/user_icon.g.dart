// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_icon.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userIconHash() => r'7135ec2117d061da0038a197e4f808b71ba5dd6a';

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

abstract class _$UserIcon extends BuildlessAsyncNotifier<Uint8List?> {
  late final Snowflake userId;

  FutureOr<Uint8List?> build(
    Snowflake userId,
  );
}

/// Get the icon of a given user by id
///
/// Copied from [UserIcon].
@ProviderFor(UserIcon)
const userIconProvider = UserIconFamily();

/// Get the icon of a given user by id
///
/// Copied from [UserIcon].
class UserIconFamily extends Family<AsyncValue<Uint8List?>> {
  /// Get the icon of a given user by id
  ///
  /// Copied from [UserIcon].
  const UserIconFamily();

  /// Get the icon of a given user by id
  ///
  /// Copied from [UserIcon].
  UserIconProvider call(
    Snowflake userId,
  ) {
    return UserIconProvider(
      userId,
    );
  }

  @override
  UserIconProvider getProviderOverride(
    covariant UserIconProvider provider,
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
  String? get name => r'userIconProvider';
}

/// Get the icon of a given user by id
///
/// Copied from [UserIcon].
class UserIconProvider extends AsyncNotifierProviderImpl<UserIcon, Uint8List?> {
  /// Get the icon of a given user by id
  ///
  /// Copied from [UserIcon].
  UserIconProvider(
    Snowflake userId,
  ) : this._internal(
          () => UserIcon()..userId = userId,
          from: userIconProvider,
          name: r'userIconProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userIconHash,
          dependencies: UserIconFamily._dependencies,
          allTransitiveDependencies: UserIconFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserIconProvider._internal(
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
  FutureOr<Uint8List?> runNotifierBuild(
    covariant UserIcon notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(UserIcon Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserIconProvider._internal(
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
  AsyncNotifierProviderElement<UserIcon, Uint8List?> createElement() {
    return _UserIconProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserIconProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UserIconRef on AsyncNotifierProviderRef<Uint8List?> {
  /// The parameter `userId` of this provider.
  Snowflake get userId;
}

class _UserIconProviderElement
    extends AsyncNotifierProviderElement<UserIcon, Uint8List?>
    with UserIconRef {
  _UserIconProviderElement(super.provider);

  @override
  Snowflake get userId => (origin as UserIconProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
