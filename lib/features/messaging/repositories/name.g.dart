// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageAuthorNameHash() => r'012e9e377dfc172764fa8794f055f01163a99cb3';

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

/// See also [messageAuthorName].
@ProviderFor(messageAuthorName)
const messageAuthorNameProvider = MessageAuthorNameFamily();

/// See also [messageAuthorName].
class MessageAuthorNameFamily extends Family<AsyncValue<String?>> {
  /// See also [messageAuthorName].
  const MessageAuthorNameFamily();

  /// See also [messageAuthorName].
  MessageAuthorNameProvider call(
    Snowflake guildId,
    Channel channel,
    MessageAuthor author,
  ) {
    return MessageAuthorNameProvider(
      guildId,
      channel,
      author,
    );
  }

  @override
  MessageAuthorNameProvider getProviderOverride(
    covariant MessageAuthorNameProvider provider,
  ) {
    return call(
      provider.guildId,
      provider.channel,
      provider.author,
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
  String? get name => r'messageAuthorNameProvider';
}

/// See also [messageAuthorName].
class MessageAuthorNameProvider extends AutoDisposeFutureProvider<String?> {
  /// See also [messageAuthorName].
  MessageAuthorNameProvider(
    Snowflake guildId,
    Channel channel,
    MessageAuthor author,
  ) : this._internal(
          (ref) => messageAuthorName(
            ref as MessageAuthorNameRef,
            guildId,
            channel,
            author,
          ),
          from: messageAuthorNameProvider,
          name: r'messageAuthorNameProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messageAuthorNameHash,
          dependencies: MessageAuthorNameFamily._dependencies,
          allTransitiveDependencies:
              MessageAuthorNameFamily._allTransitiveDependencies,
          guildId: guildId,
          channel: channel,
          author: author,
        );

  MessageAuthorNameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guildId,
    required this.channel,
    required this.author,
  }) : super.internal();

  final Snowflake guildId;
  final Channel channel;
  final MessageAuthor author;

  @override
  Override overrideWith(
    FutureOr<String?> Function(MessageAuthorNameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageAuthorNameProvider._internal(
        (ref) => create(ref as MessageAuthorNameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guildId: guildId,
        channel: channel,
        author: author,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _MessageAuthorNameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageAuthorNameProvider &&
        other.guildId == guildId &&
        other.channel == channel &&
        other.author == author;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);
    hash = _SystemHash.combine(hash, channel.hashCode);
    hash = _SystemHash.combine(hash, author.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageAuthorNameRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;

  /// The parameter `channel` of this provider.
  Channel get channel;

  /// The parameter `author` of this provider.
  MessageAuthor get author;
}

class _MessageAuthorNameProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with MessageAuthorNameRef {
  _MessageAuthorNameProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as MessageAuthorNameProvider).guildId;
  @override
  Channel get channel => (origin as MessageAuthorNameProvider).channel;
  @override
  MessageAuthor get author => (origin as MessageAuthorNameProvider).author;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
