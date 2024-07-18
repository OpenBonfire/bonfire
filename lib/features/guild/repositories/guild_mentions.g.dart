// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_mentions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guildMentionsHash() => r'2fc9cf99848fdd75e91ffb0d9d284dbb1fe08aa1';

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

abstract class _$GuildMentions extends BuildlessAsyncNotifier<int> {
  late final Snowflake guildId;

  FutureOr<int> build(
    Snowflake guildId,
  );
}

/// See also [GuildMentions].
@ProviderFor(GuildMentions)
const guildMentionsProvider = GuildMentionsFamily();

/// See also [GuildMentions].
class GuildMentionsFamily extends Family<AsyncValue<int>> {
  /// See also [GuildMentions].
  const GuildMentionsFamily();

  /// See also [GuildMentions].
  GuildMentionsProvider call(
    Snowflake guildId,
  ) {
    return GuildMentionsProvider(
      guildId,
    );
  }

  @override
  GuildMentionsProvider getProviderOverride(
    covariant GuildMentionsProvider provider,
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
  String? get name => r'guildMentionsProvider';
}

/// See also [GuildMentions].
class GuildMentionsProvider
    extends AsyncNotifierProviderImpl<GuildMentions, int> {
  /// See also [GuildMentions].
  GuildMentionsProvider(
    Snowflake guildId,
  ) : this._internal(
          () => GuildMentions()..guildId = guildId,
          from: guildMentionsProvider,
          name: r'guildMentionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$guildMentionsHash,
          dependencies: GuildMentionsFamily._dependencies,
          allTransitiveDependencies:
              GuildMentionsFamily._allTransitiveDependencies,
          guildId: guildId,
        );

  GuildMentionsProvider._internal(
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
  FutureOr<int> runNotifierBuild(
    covariant GuildMentions notifier,
  ) {
    return notifier.build(
      guildId,
    );
  }

  @override
  Override overrideWith(GuildMentions Function() create) {
    return ProviderOverride(
      origin: this,
      override: GuildMentionsProvider._internal(
        () => create()..guildId = guildId,
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
  AsyncNotifierProviderElement<GuildMentions, int> createElement() {
    return _GuildMentionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GuildMentionsProvider && other.guildId == guildId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GuildMentionsRef on AsyncNotifierProviderRef<int> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;
}

class _GuildMentionsProviderElement
    extends AsyncNotifierProviderElement<GuildMentions, int>
    with GuildMentionsRef {
  _GuildMentionsProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as GuildMentionsProvider).guildId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
