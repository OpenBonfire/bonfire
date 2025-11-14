// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reactions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageReactionsHash() => r'a2b298d8c547a393caf2dddff274f63552de2b60';

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

abstract class _$MessageReactions extends BuildlessNotifier<List<Reaction>?> {
  late final Snowflake messageId;

  List<Reaction>? build(
    Snowflake messageId,
  );
}

/// See also [MessageReactions].
@ProviderFor(MessageReactions)
const messageReactionsProvider = MessageReactionsFamily();

/// See also [MessageReactions].
class MessageReactionsFamily extends Family<List<Reaction>?> {
  /// See also [MessageReactions].
  const MessageReactionsFamily();

  /// See also [MessageReactions].
  MessageReactionsProvider call(
    Snowflake messageId,
  ) {
    return MessageReactionsProvider(
      messageId,
    );
  }

  @override
  MessageReactionsProvider getProviderOverride(
    covariant MessageReactionsProvider provider,
  ) {
    return call(
      provider.messageId,
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
  String? get name => r'messageReactionsProvider';
}

/// See also [MessageReactions].
class MessageReactionsProvider
    extends NotifierProviderImpl<MessageReactions, List<Reaction>?> {
  /// See also [MessageReactions].
  MessageReactionsProvider(
    Snowflake messageId,
  ) : this._internal(
          () => MessageReactions()..messageId = messageId,
          from: messageReactionsProvider,
          name: r'messageReactionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messageReactionsHash,
          dependencies: MessageReactionsFamily._dependencies,
          allTransitiveDependencies:
              MessageReactionsFamily._allTransitiveDependencies,
          messageId: messageId,
        );

  MessageReactionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.messageId,
  }) : super.internal();

  final Snowflake messageId;

  @override
  List<Reaction>? runNotifierBuild(
    covariant MessageReactions notifier,
  ) {
    return notifier.build(
      messageId,
    );
  }

  @override
  Override overrideWith(MessageReactions Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageReactionsProvider._internal(
        () => create()..messageId = messageId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        messageId: messageId,
      ),
    );
  }

  @override
  NotifierProviderElement<MessageReactions, List<Reaction>?> createElement() {
    return _MessageReactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageReactionsProvider && other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageReactionsRef on NotifierProviderRef<List<Reaction>?> {
  /// The parameter `messageId` of this provider.
  Snowflake get messageId;
}

class _MessageReactionsProviderElement
    extends NotifierProviderElement<MessageReactions, List<Reaction>?>
    with MessageReactionsRef {
  _MessageReactionsProviderElement(super.provider);

  @override
  Snowflake get messageId => (origin as MessageReactionsProvider).messageId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
