// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$channelControllerHash() => r'1d5f6f3b9b446afdab96896cdc9e17b8f2106ea4';

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

abstract class _$ChannelController
    extends BuildlessAutoDisposeAsyncNotifier<Channel?> {
  late final String channelId;

  FutureOr<Channel?> build(
    String channelId,
  );
}

/// Fetches the current channel from the [channelid].
///
/// Copied from [ChannelController].
@ProviderFor(ChannelController)
const channelControllerProvider = ChannelControllerFamily();

/// Fetches the current channel from the [channelid].
///
/// Copied from [ChannelController].
class ChannelControllerFamily extends Family<AsyncValue<Channel?>> {
  /// Fetches the current channel from the [channelid].
  ///
  /// Copied from [ChannelController].
  const ChannelControllerFamily();

  /// Fetches the current channel from the [channelid].
  ///
  /// Copied from [ChannelController].
  ChannelControllerProvider call(
    String channelId,
  ) {
    return ChannelControllerProvider(
      channelId,
    );
  }

  @override
  ChannelControllerProvider getProviderOverride(
    covariant ChannelControllerProvider provider,
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
  String? get name => r'channelControllerProvider';
}

/// Fetches the current channel from the [channelid].
///
/// Copied from [ChannelController].
class ChannelControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChannelController, Channel?> {
  /// Fetches the current channel from the [channelid].
  ///
  /// Copied from [ChannelController].
  ChannelControllerProvider(
    String channelId,
  ) : this._internal(
          () => ChannelController()..channelId = channelId,
          from: channelControllerProvider,
          name: r'channelControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$channelControllerHash,
          dependencies: ChannelControllerFamily._dependencies,
          allTransitiveDependencies:
              ChannelControllerFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  ChannelControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.channelId,
  }) : super.internal();

  final String channelId;

  @override
  FutureOr<Channel?> runNotifierBuild(
    covariant ChannelController notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(ChannelController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChannelControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ChannelController, Channel?>
      createElement() {
    return _ChannelControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelControllerProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChannelControllerRef on AutoDisposeAsyncNotifierProviderRef<Channel?> {
  /// The parameter `channelId` of this provider.
  String get channelId;
}

class _ChannelControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChannelController, Channel?>
    with ChannelControllerRef {
  _ChannelControllerProviderElement(super.provider);

  @override
  String get channelId => (origin as ChannelControllerProvider).channelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
