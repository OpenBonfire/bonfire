// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_icon.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guildIconHash() => r'2834302f8117083853bbc23f660e8b705f98c121';

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

/// See also [guildIcon].
@ProviderFor(guildIcon)
const guildIconProvider = GuildIconFamily();

/// See also [guildIcon].
class GuildIconFamily extends Family<AsyncValue<Uint8List?>> {
  /// See also [guildIcon].
  const GuildIconFamily();

  /// See also [guildIcon].
  GuildIconProvider call(
    Snowflake guildId,
  ) {
    return GuildIconProvider(
      guildId,
    );
  }

  @override
  GuildIconProvider getProviderOverride(
    covariant GuildIconProvider provider,
  ) {
    return call(
      provider.guildId,
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
  String? get name => r'guildIconProvider';
}

/// See also [guildIcon].
class GuildIconProvider extends FutureProvider<Uint8List?> {
  /// See also [guildIcon].
  GuildIconProvider(
    Snowflake guildId,
  ) : this._internal(
          (ref) => guildIcon(
            ref as GuildIconRef,
            guildId,
          ),
          from: guildIconProvider,
          name: r'guildIconProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$guildIconHash,
          dependencies: GuildIconFamily._dependencies,
          allTransitiveDependencies: GuildIconFamily._allTransitiveDependencies,
          guildId: guildId,
        );

  GuildIconProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guildId,
  }) : super.internal();

  final Snowflake guildId;

  @override
  Override overrideWith(
    FutureOr<Uint8List?> Function(GuildIconRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GuildIconProvider._internal(
        (ref) => create(ref as GuildIconRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guildId: guildId,
      ),
    );
  }

  @override
  FutureProviderElement<Uint8List?> createElement() {
    return _GuildIconProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GuildIconProvider && other.guildId == guildId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GuildIconRef on FutureProviderRef<Uint8List?> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;
}

class _GuildIconProviderElement extends FutureProviderElement<Uint8List?>
    with GuildIconRef {
  _GuildIconProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as GuildIconProvider).guildId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
