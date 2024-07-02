// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channels.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$channelsHash() => r'c475dd47f72e21934223ca67a124e180ca1be17d';

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

abstract class _$Channels extends BuildlessAsyncNotifier<List<Channel>> {
  late final Snowflake guildId;

  FutureOr<List<Channel>> build(
    Snowflake guildId,
  );
}

/// A riverpod provider that fetches the channels for the current guild.
///
/// Copied from [Channels].
@ProviderFor(Channels)
const channelsProvider = ChannelsFamily();

/// A riverpod provider that fetches the channels for the current guild.
///
/// Copied from [Channels].
class ChannelsFamily extends Family<AsyncValue<List<Channel>>> {
  /// A riverpod provider that fetches the channels for the current guild.
  ///
  /// Copied from [Channels].
  const ChannelsFamily();

  /// A riverpod provider that fetches the channels for the current guild.
  ///
  /// Copied from [Channels].
  ChannelsProvider call(
    Snowflake guildId,
  ) {
    return ChannelsProvider(
      guildId,
    );
  }

  @override
  ChannelsProvider getProviderOverride(
    covariant ChannelsProvider provider,
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
  String? get name => r'channelsProvider';
}

/// A riverpod provider that fetches the channels for the current guild.
///
/// Copied from [Channels].
class ChannelsProvider
    extends AsyncNotifierProviderImpl<Channels, List<Channel>> {
  /// A riverpod provider that fetches the channels for the current guild.
  ///
  /// Copied from [Channels].
  ChannelsProvider(
    Snowflake guildId,
  ) : this._internal(
          () => Channels()..guildId = guildId,
          from: channelsProvider,
          name: r'channelsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$channelsHash,
          dependencies: ChannelsFamily._dependencies,
          allTransitiveDependencies: ChannelsFamily._allTransitiveDependencies,
          guildId: guildId,
        );

  ChannelsProvider._internal(
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
  FutureOr<List<Channel>> runNotifierBuild(
    covariant Channels notifier,
  ) {
    return notifier.build(
      guildId,
    );
  }

  @override
  Override overrideWith(Channels Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChannelsProvider._internal(
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
  AsyncNotifierProviderElement<Channels, List<Channel>> createElement() {
    return _ChannelsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelsProvider && other.guildId == guildId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChannelsRef on AsyncNotifierProviderRef<List<Channel>> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;
}

class _ChannelsProviderElement
    extends AsyncNotifierProviderElement<Channels, List<Channel>>
    with ChannelsRef {
  _ChannelsProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as ChannelsProvider).guildId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
