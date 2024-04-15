// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guilds.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guildsHash() => r'608841d6d2607c52c8f9cd51a804575133c018b7';

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

/// See also [guilds].
@ProviderFor(guilds)
const guildsProvider = GuildsFamily();

/// See also [guilds].
class GuildsFamily extends Family<AsyncValue<List<UserGuild>>> {
  /// See also [guilds].
  const GuildsFamily();

  /// See also [guilds].
  GuildsProvider call(
    NyxxGateway client,
  ) {
    return GuildsProvider(
      client,
    );
  }

  @override
  GuildsProvider getProviderOverride(
    covariant GuildsProvider provider,
  ) {
    return call(
      provider.client,
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
  String? get name => r'guildsProvider';
}

/// See also [guilds].
class GuildsProvider extends AutoDisposeFutureProvider<List<UserGuild>> {
  /// See also [guilds].
  GuildsProvider(
    NyxxGateway client,
  ) : this._internal(
          (ref) => guilds(
            ref as GuildsRef,
            client,
          ),
          from: guildsProvider,
          name: r'guildsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$guildsHash,
          dependencies: GuildsFamily._dependencies,
          allTransitiveDependencies: GuildsFamily._allTransitiveDependencies,
          client: client,
        );

  GuildsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.client,
  }) : super.internal();

  final NyxxGateway client;

  @override
  Override overrideWith(
    FutureOr<List<UserGuild>> Function(GuildsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GuildsProvider._internal(
        (ref) => create(ref as GuildsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        client: client,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UserGuild>> createElement() {
    return _GuildsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GuildsProvider && other.client == client;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, client.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GuildsRef on AutoDisposeFutureProviderRef<List<UserGuild>> {
  /// The parameter `client` of this provider.
  NyxxGateway get client;
}

class _GuildsProviderElement
    extends AutoDisposeFutureProviderElement<List<UserGuild>> with GuildsRef {
  _GuildsProviderElement(super.provider);

  @override
  NyxxGateway get client => (origin as GuildsProvider).client;
}

String _$guildHash() => r'6593a6995dce9f3d116d96ca4aea2d43c7f0a4b6';

/// See also [guild].
@ProviderFor(guild)
const guildProvider = GuildFamily();

/// See also [guild].
class GuildFamily extends Family<AsyncValue<Guild>> {
  /// See also [guild].
  const GuildFamily();

  /// See also [guild].
  GuildProvider call(
    NyxxGateway client,
    Snowflake id,
  ) {
    return GuildProvider(
      client,
      id,
    );
  }

  @override
  GuildProvider getProviderOverride(
    covariant GuildProvider provider,
  ) {
    return call(
      provider.client,
      provider.id,
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
  String? get name => r'guildProvider';
}

/// See also [guild].
class GuildProvider extends AutoDisposeFutureProvider<Guild> {
  /// See also [guild].
  GuildProvider(
    NyxxGateway client,
    Snowflake id,
  ) : this._internal(
          (ref) => guild(
            ref as GuildRef,
            client,
            id,
          ),
          from: guildProvider,
          name: r'guildProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$guildHash,
          dependencies: GuildFamily._dependencies,
          allTransitiveDependencies: GuildFamily._allTransitiveDependencies,
          client: client,
          id: id,
        );

  GuildProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.client,
    required this.id,
  }) : super.internal();

  final NyxxGateway client;
  final Snowflake id;

  @override
  Override overrideWith(
    FutureOr<Guild> Function(GuildRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GuildProvider._internal(
        (ref) => create(ref as GuildRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        client: client,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Guild> createElement() {
    return _GuildProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GuildProvider && other.client == client && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, client.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GuildRef on AutoDisposeFutureProviderRef<Guild> {
  /// The parameter `client` of this provider.
  NyxxGateway get client;

  /// The parameter `id` of this provider.
  Snowflake get id;
}

class _GuildProviderElement extends AutoDisposeFutureProviderElement<Guild>
    with GuildRef {
  _GuildProviderElement(super.provider);

  @override
  NyxxGateway get client => (origin as GuildProvider).client;
  @override
  Snowflake get id => (origin as GuildProvider).id;
}

String _$channelsHash() => r'214f3e59242233a59218e00a3774939819fa9214';

/// See also [channels].
@ProviderFor(channels)
const channelsProvider = ChannelsFamily();

/// See also [channels].
class ChannelsFamily extends Family<AsyncValue<List<GuildChannel>>> {
  /// See also [channels].
  const ChannelsFamily();

  /// See also [channels].
  ChannelsProvider call(
    NyxxGateway client,
    Guild guild,
  ) {
    return ChannelsProvider(
      client,
      guild,
    );
  }

  @override
  ChannelsProvider getProviderOverride(
    covariant ChannelsProvider provider,
  ) {
    return call(
      provider.client,
      provider.guild,
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
  String? get name => r'channelsProvider';
}

/// See also [channels].
class ChannelsProvider extends AutoDisposeFutureProvider<List<GuildChannel>> {
  /// See also [channels].
  ChannelsProvider(
    NyxxGateway client,
    Guild guild,
  ) : this._internal(
          (ref) => channels(
            ref as ChannelsRef,
            client,
            guild,
          ),
          from: channelsProvider,
          name: r'channelsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$channelsHash,
          dependencies: ChannelsFamily._dependencies,
          allTransitiveDependencies: ChannelsFamily._allTransitiveDependencies,
          client: client,
          guild: guild,
        );

  ChannelsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.client,
    required this.guild,
  }) : super.internal();

  final NyxxGateway client;
  final Guild guild;

  @override
  Override overrideWith(
    FutureOr<List<GuildChannel>> Function(ChannelsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChannelsProvider._internal(
        (ref) => create(ref as ChannelsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        client: client,
        guild: guild,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<GuildChannel>> createElement() {
    return _ChannelsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelsProvider &&
        other.client == client &&
        other.guild == guild;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, client.hashCode);
    hash = _SystemHash.combine(hash, guild.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChannelsRef on AutoDisposeFutureProviderRef<List<GuildChannel>> {
  /// The parameter `client` of this provider.
  NyxxGateway get client;

  /// The parameter `guild` of this provider.
  Guild get guild;
}

class _ChannelsProviderElement
    extends AutoDisposeFutureProviderElement<List<GuildChannel>>
    with ChannelsRef {
  _ChannelsProviderElement(super.provider);

  @override
  NyxxGateway get client => (origin as ChannelsProvider).client;
  @override
  Guild get guild => (origin as ChannelsProvider).guild;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
