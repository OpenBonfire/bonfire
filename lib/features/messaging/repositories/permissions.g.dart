// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$channelPermissionsHash() =>
    r'ab65ba280e705f2edce1f71dfbd7dc9d1a9edf29';

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

abstract class _$ChannelPermissions
    extends BuildlessAsyncNotifier<Permissions?> {
  late final Snowflake channelId;

  FutureOr<Permissions?> build(
    Snowflake channelId,
  );
}

/// Provider for calculating permissions for a channel
///
/// Copied from [ChannelPermissions].
@ProviderFor(ChannelPermissions)
const channelPermissionsProvider = ChannelPermissionsFamily();

/// Provider for calculating permissions for a channel
///
/// Copied from [ChannelPermissions].
class ChannelPermissionsFamily extends Family<AsyncValue<Permissions?>> {
  /// Provider for calculating permissions for a channel
  ///
  /// Copied from [ChannelPermissions].
  const ChannelPermissionsFamily();

  /// Provider for calculating permissions for a channel
  ///
  /// Copied from [ChannelPermissions].
  ChannelPermissionsProvider call(
    Snowflake channelId,
  ) {
    return ChannelPermissionsProvider(
      channelId,
    );
  }

  @override
  ChannelPermissionsProvider getProviderOverride(
    covariant ChannelPermissionsProvider provider,
  ) {
    return call(
      provider.channelId,
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
  String? get name => r'channelPermissionsProvider';
}

/// Provider for calculating permissions for a channel
///
/// Copied from [ChannelPermissions].
class ChannelPermissionsProvider
    extends AsyncNotifierProviderImpl<ChannelPermissions, Permissions?> {
  /// Provider for calculating permissions for a channel
  ///
  /// Copied from [ChannelPermissions].
  ChannelPermissionsProvider(
    Snowflake channelId,
  ) : this._internal(
          () => ChannelPermissions()..channelId = channelId,
          from: channelPermissionsProvider,
          name: r'channelPermissionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$channelPermissionsHash,
          dependencies: ChannelPermissionsFamily._dependencies,
          allTransitiveDependencies:
              ChannelPermissionsFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  ChannelPermissionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.channelId,
  }) : super.internal();

  final Snowflake channelId;

  @override
  FutureOr<Permissions?> runNotifierBuild(
    covariant ChannelPermissions notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(ChannelPermissions Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChannelPermissionsProvider._internal(
        () => create()..channelId = channelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        channelId: channelId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<ChannelPermissions, Permissions?>
      createElement() {
    return _ChannelPermissionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelPermissionsProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChannelPermissionsRef on AsyncNotifierProviderRef<Permissions?> {
  /// The parameter `channelId` of this provider.
  Snowflake get channelId;
}

class _ChannelPermissionsProviderElement
    extends AsyncNotifierProviderElement<ChannelPermissions, Permissions?>
    with ChannelPermissionsRef {
  _ChannelPermissionsProviderElement(super.provider);

  @override
  Snowflake get channelId => (origin as ChannelPermissionsProvider).channelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
