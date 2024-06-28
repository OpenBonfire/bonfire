// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guildBannerUrlHash() => r'9e167e4f6fcf91304307e45593d8eeea81103013';

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

/// See also [guildBannerUrl].
@ProviderFor(guildBannerUrl)
const guildBannerUrlProvider = GuildBannerUrlFamily();

/// See also [guildBannerUrl].
class GuildBannerUrlFamily extends Family<AsyncValue<Uri?>> {
  /// See also [guildBannerUrl].
  const GuildBannerUrlFamily();

  /// See also [guildBannerUrl].
  GuildBannerUrlProvider call(
    Guild guild,
  ) {
    return GuildBannerUrlProvider(
      guild,
    );
  }

  @override
  GuildBannerUrlProvider getProviderOverride(
    covariant GuildBannerUrlProvider provider,
  ) {
    return call(
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
  String? get name => r'guildBannerUrlProvider';
}

/// See also [guildBannerUrl].
class GuildBannerUrlProvider extends AutoDisposeFutureProvider<Uri?> {
  /// See also [guildBannerUrl].
  GuildBannerUrlProvider(
    Guild guild,
  ) : this._internal(
          (ref) => guildBannerUrl(
            ref as GuildBannerUrlRef,
            guild,
          ),
          from: guildBannerUrlProvider,
          name: r'guildBannerUrlProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$guildBannerUrlHash,
          dependencies: GuildBannerUrlFamily._dependencies,
          allTransitiveDependencies:
              GuildBannerUrlFamily._allTransitiveDependencies,
          guild: guild,
        );

  GuildBannerUrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guild,
  }) : super.internal();

  final Guild guild;

  @override
  Override overrideWith(
    FutureOr<Uri?> Function(GuildBannerUrlRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GuildBannerUrlProvider._internal(
        (ref) => create(ref as GuildBannerUrlRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guild: guild,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Uri?> createElement() {
    return _GuildBannerUrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GuildBannerUrlProvider && other.guild == guild;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guild.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GuildBannerUrlRef on AutoDisposeFutureProviderRef<Uri?> {
  /// The parameter `guild` of this provider.
  Guild get guild;
}

class _GuildBannerUrlProviderElement
    extends AutoDisposeFutureProviderElement<Uri?> with GuildBannerUrlRef {
  _GuildBannerUrlProviderElement(super.provider);

  @override
  Guild get guild => (origin as GuildBannerUrlProvider).guild;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
