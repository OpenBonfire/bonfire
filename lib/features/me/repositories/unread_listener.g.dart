// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_listener.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadListenerHash() => r'41807ac8eaea02b2f8503b0a6295404c87fed414';

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

abstract class _$UnreadListener extends BuildlessAutoDisposeNotifier<bool> {
  late final Snowflake channelId;

  bool build(
    Snowflake channelId,
  );
}

/// See also [UnreadListener].
@ProviderFor(UnreadListener)
const unreadListenerProvider = UnreadListenerFamily();

/// See also [UnreadListener].
class UnreadListenerFamily extends Family<bool> {
  /// See also [UnreadListener].
  const UnreadListenerFamily();

  /// See also [UnreadListener].
  UnreadListenerProvider call(
    Snowflake channelId,
  ) {
    return UnreadListenerProvider(
      channelId,
    );
  }

  @override
  UnreadListenerProvider getProviderOverride(
    covariant UnreadListenerProvider provider,
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
  String? get name => r'unreadListenerProvider';
}

/// See also [UnreadListener].
class UnreadListenerProvider
    extends AutoDisposeNotifierProviderImpl<UnreadListener, bool> {
  /// See also [UnreadListener].
  UnreadListenerProvider(
    Snowflake channelId,
  ) : this._internal(
          () => UnreadListener()..channelId = channelId,
          from: unreadListenerProvider,
          name: r'unreadListenerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unreadListenerHash,
          dependencies: UnreadListenerFamily._dependencies,
          allTransitiveDependencies:
              UnreadListenerFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  UnreadListenerProvider._internal(
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
  bool runNotifierBuild(
    covariant UnreadListener notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(UnreadListener Function() create) {
    return ProviderOverride(
      origin: this,
      override: UnreadListenerProvider._internal(
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
  AutoDisposeNotifierProviderElement<UnreadListener, bool> createElement() {
    return _UnreadListenerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadListenerProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UnreadListenerRef on AutoDisposeNotifierProviderRef<bool> {
  /// The parameter `channelId` of this provider.
  Snowflake get channelId;
}

class _UnreadListenerProviderElement
    extends AutoDisposeNotifierProviderElement<UnreadListener, bool>
    with UnreadListenerRef {
  _UnreadListenerProviderElement(super.provider);

  @override
  Snowflake get channelId => (origin as UnreadListenerProvider).channelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
