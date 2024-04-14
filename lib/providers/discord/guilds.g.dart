// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guilds.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guildsHash() => r'f4b801988a296de7f84ff4898465ed933a950783';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
