// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageSearchHash() => r'aee504655bf2f7fcc58c6964514a2072d9433098';

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

abstract class _$MessageSearch extends BuildlessAsyncNotifier<List<Message>?> {
  late final Snowflake guildId;
  late final String query;

  FutureOr<List<Message>?> build(
    Snowflake guildId,
    String query,
  );
}

/// See also [MessageSearch].
@ProviderFor(MessageSearch)
const messageSearchProvider = MessageSearchFamily();

/// See also [MessageSearch].
class MessageSearchFamily extends Family<AsyncValue<List<Message>?>> {
  /// See also [MessageSearch].
  const MessageSearchFamily();

  /// See also [MessageSearch].
  MessageSearchProvider call(
    Snowflake guildId,
    String query,
  ) {
    return MessageSearchProvider(
      guildId,
      query,
    );
  }

  @override
  MessageSearchProvider getProviderOverride(
    covariant MessageSearchProvider provider,
  ) {
    return call(
      provider.guildId,
      provider.query,
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
  String? get name => r'messageSearchProvider';
}

/// See also [MessageSearch].
class MessageSearchProvider
    extends AsyncNotifierProviderImpl<MessageSearch, List<Message>?> {
  /// See also [MessageSearch].
  MessageSearchProvider(
    Snowflake guildId,
    String query,
  ) : this._internal(
          () => MessageSearch()
            ..guildId = guildId
            ..query = query,
          from: messageSearchProvider,
          name: r'messageSearchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messageSearchHash,
          dependencies: MessageSearchFamily._dependencies,
          allTransitiveDependencies:
              MessageSearchFamily._allTransitiveDependencies,
          guildId: guildId,
          query: query,
        );

  MessageSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guildId,
    required this.query,
  }) : super.internal();

  final Snowflake guildId;
  final String query;

  @override
  FutureOr<List<Message>?> runNotifierBuild(
    covariant MessageSearch notifier,
  ) {
    return notifier.build(
      guildId,
      query,
    );
  }

  @override
  Override overrideWith(MessageSearch Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageSearchProvider._internal(
        () => create()
          ..guildId = guildId
          ..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guildId: guildId,
        query: query,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<MessageSearch, List<Message>?> createElement() {
    return _MessageSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageSearchProvider &&
        other.guildId == guildId &&
        other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageSearchRef on AsyncNotifierProviderRef<List<Message>?> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;

  /// The parameter `query` of this provider.
  String get query;
}

class _MessageSearchProviderElement
    extends AsyncNotifierProviderElement<MessageSearch, List<Message>?>
    with MessageSearchRef {
  _MessageSearchProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as MessageSearchProvider).guildId;
  @override
  String get query => (origin as MessageSearchProvider).query;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
