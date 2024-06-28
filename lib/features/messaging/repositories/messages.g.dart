// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesHash() => r'9490b5b276e8cdb2b09283bcaaa03157c19848a9';

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

abstract class _$Messages
    extends BuildlessAutoDisposeAsyncNotifier<List<Message>> {
  late final Guild guild;
  late final Channel channel;

  FutureOr<List<Message>> build(
    Guild guild,
    Channel channel,
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
class MessagesFamily extends Family<AsyncValue<List<Message>>> {
  /// Message provider for fetching messages from the Discord API
  ///
  /// Copied from [Messages].
  const MessagesFamily();

  /// Message provider for fetching messages from the Discord API
  ///
  /// Copied from [Messages].
  MessagesProvider call(
    Guild guild,
    Channel channel,
  ) {
    return MessagesProvider(
      guild,
      channel,
    );
  }

  @override
  MessagesProvider getProviderOverride(
    covariant MessagesProvider provider,
  ) {
    return call(
      provider.guild,
      provider.channel,
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
    extends AutoDisposeAsyncNotifierProviderImpl<Messages, List<Message>> {
  /// Message provider for fetching messages from the Discord API
  ///
  /// Copied from [Messages].
  MessagesProvider(
    Guild guild,
    Channel channel,
  ) : this._internal(
          () => Messages()
            ..guild = guild
            ..channel = channel,
          from: messagesProvider,
          name: r'messagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messagesHash,
          dependencies: MessagesFamily._dependencies,
          allTransitiveDependencies: MessagesFamily._allTransitiveDependencies,
          guild: guild,
          channel: channel,
        );

  MessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guild,
    required this.channel,
  }) : super.internal();

  final Guild guild;
  final Channel channel;

  @override
  FutureOr<List<Message>> runNotifierBuild(
    covariant Messages notifier,
  ) {
    return notifier.build(
      guild,
      channel,
    );
  }

  @override
  Override overrideWith(Messages Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessagesProvider._internal(
        () => create()
          ..guild = guild
          ..channel = channel,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guild: guild,
        channel: channel,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<Messages, List<Message>>
      createElement() {
    return _MessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider &&
        other.guild == guild &&
        other.channel == channel;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guild.hashCode);
    hash = _SystemHash.combine(hash, channel.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MessagesRef on AutoDisposeAsyncNotifierProviderRef<List<Message>> {
  /// The parameter `guild` of this provider.
  Guild get guild;

  /// The parameter `channel` of this provider.
  Channel get channel;
}

class _MessagesProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Messages, List<Message>>
    with MessagesRef {
  _MessagesProviderElement(super.provider);

  @override
  Guild get guild => (origin as MessagesProvider).guild;
  @override
  Channel get channel => (origin as MessagesProvider).channel;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
