// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channels.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$channelsHash() => r'1a786aec9bdf6dbd8bee8a206dfcad63efef3e93';

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

abstract class _$Channels
    extends BuildlessAutoDisposeAsyncNotifier<List<Channel>> {
  late final Guild guild;

  FutureOr<List<Channel>> build(
    Guild guild,
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
    Guild guild,
  ) {
    return ChannelsProvider(
      guild,
    );
  }

  @override
  ChannelsProvider getProviderOverride(
    covariant ChannelsProvider provider,
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
  String? get name => r'channelsProvider';
}

/// A riverpod provider that fetches the channels for the current guild.
///
/// Copied from [Channels].
class ChannelsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Channels, List<Channel>> {
  /// A riverpod provider that fetches the channels for the current guild.
  ///
  /// Copied from [Channels].
  ChannelsProvider(
    Guild guild,
  ) : this._internal(
          () => Channels()..guild = guild,
          from: channelsProvider,
          name: r'channelsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$channelsHash,
          dependencies: ChannelsFamily._dependencies,
          allTransitiveDependencies: ChannelsFamily._allTransitiveDependencies,
          guild: guild,
        );

  ChannelsProvider._internal(
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
  FutureOr<List<Channel>> runNotifierBuild(
    covariant Channels notifier,
  ) {
    return notifier.build(
      guild,
    );
  }

  @override
  Override overrideWith(Channels Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChannelsProvider._internal(
        () => create()..guild = guild,
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
  AutoDisposeAsyncNotifierProviderElement<Channels, List<Channel>>
      createElement() {
    return _ChannelsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelsProvider && other.guild == guild;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guild.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChannelsRef on AutoDisposeAsyncNotifierProviderRef<List<Channel>> {
  /// The parameter `guild` of this provider.
  Guild get guild;
}

class _ChannelsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Channels, List<Channel>>
    with ChannelsRef {
  _ChannelsProviderElement(super.provider);

  @override
  Guild get guild => (origin as ChannelsProvider).guild;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
