// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesHash() => r'16748f93a3ac2ffe610a4956e065d59d846ffe82';

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

abstract class _$Messages extends BuildlessAsyncNotifier<List<Message>?> {
  late final Snowflake channelId;

  FutureOr<List<Message>?> build(
    Snowflake channelId,
  );
}

/// Message provider for fetching messages from the Discord API
///
/// Copied from [Messages].
@ProviderFor(Messages)
const messagesProvider = MessagesFamily();

/// Message provider for fetching messages from the Discord API
///
/// Copied from [Messages].
class MessagesFamily extends Family<AsyncValue<List<Message>?>> {
  /// Message provider for fetching messages from the Discord API
  ///
  /// Copied from [Messages].
  const MessagesFamily();

  /// Message provider for fetching messages from the Discord API
  ///
  /// Copied from [Messages].
  MessagesProvider call(
    Snowflake channelId,
  ) {
    return MessagesProvider(
      channelId,
    );
  }

  @override
  MessagesProvider getProviderOverride(
    covariant MessagesProvider provider,
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
  String? get name => r'messagesProvider';
}

/// Message provider for fetching messages from the Discord API
///
/// Copied from [Messages].
class MessagesProvider
    extends AsyncNotifierProviderImpl<Messages, List<Message>?> {
  /// Message provider for fetching messages from the Discord API
  ///
  /// Copied from [Messages].
  MessagesProvider(
    Snowflake channelId,
  ) : this._internal(
          () => Messages()..channelId = channelId,
          from: messagesProvider,
          name: r'messagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messagesHash,
          dependencies: MessagesFamily._dependencies,
          allTransitiveDependencies: MessagesFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  MessagesProvider._internal(
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
  FutureOr<List<Message>?> runNotifierBuild(
    covariant Messages notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(Messages Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessagesProvider._internal(
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
  AsyncNotifierProviderElement<Messages, List<Message>?> createElement() {
    return _MessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MessagesRef on AsyncNotifierProviderRef<List<Message>?> {
  /// The parameter `channelId` of this provider.
  Snowflake get channelId;
}

class _MessagesProviderElement
    extends AsyncNotifierProviderElement<Messages, List<Message>?>
    with MessagesRef {
  _MessagesProviderElement(super.provider);

  @override
  Snowflake get channelId => (origin as MessagesProvider).channelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
