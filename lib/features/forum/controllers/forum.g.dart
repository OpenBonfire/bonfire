// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$threadChannelHash() => r'978541d1e6c62409681e1ba9c38976ee410d7465';

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

abstract class _$ThreadChannel extends BuildlessNotifier<Channel?> {
  late final Snowflake channelId;

  Channel? build(
    Snowflake channelId,
  );
}

/// See also [ThreadChannel].
@ProviderFor(ThreadChannel)
const threadChannelProvider = ThreadChannelFamily();

/// See also [ThreadChannel].
class ThreadChannelFamily extends Family<Channel?> {
  /// See also [ThreadChannel].
  const ThreadChannelFamily();

  /// See also [ThreadChannel].
  ThreadChannelProvider call(
    Snowflake channelId,
  ) {
    return ThreadChannelProvider(
      channelId,
    );
  }

  @override
  ThreadChannelProvider getProviderOverride(
    covariant ThreadChannelProvider provider,
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
  String? get name => r'threadChannelProvider';
}

/// See also [ThreadChannel].
class ThreadChannelProvider
    extends NotifierProviderImpl<ThreadChannel, Channel?> {
  /// See also [ThreadChannel].
  ThreadChannelProvider(
    Snowflake channelId,
  ) : this._internal(
          () => ThreadChannel()..channelId = channelId,
          from: threadChannelProvider,
          name: r'threadChannelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$threadChannelHash,
          dependencies: ThreadChannelFamily._dependencies,
          allTransitiveDependencies:
              ThreadChannelFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  ThreadChannelProvider._internal(
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
  Channel? runNotifierBuild(
    covariant ThreadChannel notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(ThreadChannel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ThreadChannelProvider._internal(
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
  NotifierProviderElement<ThreadChannel, Channel?> createElement() {
    return _ThreadChannelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ThreadChannelProvider && other.channelId == channelId;
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
mixin ThreadChannelRef on NotifierProviderRef<Channel?> {
  /// The parameter `channelId` of this provider.
  Snowflake get channelId;
}

class _ThreadChannelProviderElement
    extends NotifierProviderElement<ThreadChannel, Channel?>
    with ThreadChannelRef {
  _ThreadChannelProviderElement(super.provider);

  @override
  Snowflake get channelId => (origin as ThreadChannelProvider).channelId;
}

String _$firstMessageHash() => r'df3012cc799a51760acb497c92f30cb47cdac767';

abstract class _$FirstMessage extends BuildlessNotifier<Message?> {
  late final Snowflake channelId;

  Message? build(
    Snowflake channelId,
  );
}

/// See also [FirstMessage].
@ProviderFor(FirstMessage)
const firstMessageProvider = FirstMessageFamily();

/// See also [FirstMessage].
class FirstMessageFamily extends Family<Message?> {
  /// See also [FirstMessage].
  const FirstMessageFamily();

  /// See also [FirstMessage].
  FirstMessageProvider call(
    Snowflake channelId,
  ) {
    return FirstMessageProvider(
      channelId,
    );
  }

  @override
  FirstMessageProvider getProviderOverride(
    covariant FirstMessageProvider provider,
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
  String? get name => r'firstMessageProvider';
}

/// See also [FirstMessage].
class FirstMessageProvider
    extends NotifierProviderImpl<FirstMessage, Message?> {
  /// See also [FirstMessage].
  FirstMessageProvider(
    Snowflake channelId,
  ) : this._internal(
          () => FirstMessage()..channelId = channelId,
          from: firstMessageProvider,
          name: r'firstMessageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firstMessageHash,
          dependencies: FirstMessageFamily._dependencies,
          allTransitiveDependencies:
              FirstMessageFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  FirstMessageProvider._internal(
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
  Message? runNotifierBuild(
    covariant FirstMessage notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(FirstMessage Function() create) {
    return ProviderOverride(
      origin: this,
      override: FirstMessageProvider._internal(
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
  NotifierProviderElement<FirstMessage, Message?> createElement() {
    return _FirstMessageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirstMessageProvider && other.channelId == channelId;
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
mixin FirstMessageRef on NotifierProviderRef<Message?> {
  /// The parameter `channelId` of this provider.
  Snowflake get channelId;
}

class _FirstMessageProviderElement
    extends NotifierProviderElement<FirstMessage, Message?>
    with FirstMessageRef {
  _FirstMessageProviderElement(super.provider);

  @override
  Snowflake get channelId => (origin as FirstMessageProvider).channelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
