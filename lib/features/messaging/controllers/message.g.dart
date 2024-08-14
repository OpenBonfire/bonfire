// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageControllerHash() => r'6f9af65eb6afb74e44e531a4a81548c3e5b70e69';

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

abstract class _$MessageController
    extends BuildlessAutoDisposeNotifier<Snowflake?> {
  late final Snowflake messageId;

  Snowflake? build(
    Snowflake messageId,
  );
}

/// See also [MessageController].
@ProviderFor(MessageController)
const messageControllerProvider = MessageControllerFamily();

/// See also [MessageController].
class MessageControllerFamily extends Family<Snowflake?> {
  /// See also [MessageController].
  const MessageControllerFamily();

  /// See also [MessageController].
  MessageControllerProvider call(
    Snowflake messageId,
  ) {
    return MessageControllerProvider(
      messageId,
    );
  }

  @override
  MessageControllerProvider getProviderOverride(
    covariant MessageControllerProvider provider,
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
  String? get name => r'messageControllerProvider';
}

/// See also [MessageController].
class MessageControllerProvider
    extends AutoDisposeNotifierProviderImpl<MessageController, Snowflake?> {
  /// See also [MessageController].
  MessageControllerProvider(
    Snowflake messageId,
  ) : this._internal(
          () => MessageController()..messageId = messageId,
          from: messageControllerProvider,
          name: r'messageControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messageControllerHash,
          dependencies: MessageControllerFamily._dependencies,
          allTransitiveDependencies:
              MessageControllerFamily._allTransitiveDependencies,
          messageId: messageId,
        );

  MessageControllerProvider._internal(
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
  Snowflake? runNotifierBuild(
    covariant MessageController notifier,
  ) {
    return notifier.build(
      messageId,
    );
  }

  @override
  Override overrideWith(MessageController Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<MessageController, Snowflake?>
      createElement() {
    return _MessageControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageControllerProvider && other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MessageControllerRef on AutoDisposeNotifierProviderRef<Snowflake?> {
  /// The parameter `messageId` of this provider.
  Snowflake get messageId;
}

class _MessageControllerProviderElement
    extends AutoDisposeNotifierProviderElement<MessageController, Snowflake?>
    with MessageControllerRef {
  _MessageControllerProviderElement(super.provider);

  @override
  Snowflake get messageId => (origin as MessageControllerProvider).messageId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
