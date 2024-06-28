// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_members.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$channelMembersHash() => r'6a39b71847a0a6d299414462a521ee6e62bf343e';

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

abstract class _$ChannelMembers extends BuildlessAutoDisposeAsyncNotifier<
    Pair<List<GuildMemberListGroup>, List<dynamic>>?> {
  late final Guild guild;
  late final Channel channel;

  FutureOr<Pair<List<GuildMemberListGroup>, List<dynamic>>?> build(
    Guild guild,
    Channel channel,
  );
}

/// See also [ChannelMembers].
@ProviderFor(ChannelMembers)
const channelMembersProvider = ChannelMembersFamily();

/// See also [ChannelMembers].
class ChannelMembersFamily extends Family<
    AsyncValue<Pair<List<GuildMemberListGroup>, List<dynamic>>?>> {
  /// See also [ChannelMembers].
  const ChannelMembersFamily();

  /// See also [ChannelMembers].
  ChannelMembersProvider call(
    Guild guild,
    Channel channel,
  ) {
    return ChannelMembersProvider(
      guild,
      channel,
    );
  }

  @override
  ChannelMembersProvider getProviderOverride(
    covariant ChannelMembersProvider provider,
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
  String? get name => r'channelMembersProvider';
}

/// See also [ChannelMembers].
class ChannelMembersProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ChannelMembers, Pair<List<GuildMemberListGroup>, List<dynamic>>?> {
  /// See also [ChannelMembers].
  ChannelMembersProvider(
    Guild guild,
    Channel channel,
  ) : this._internal(
          () => ChannelMembers()
            ..guild = guild
            ..channel = channel,
          from: channelMembersProvider,
          name: r'channelMembersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$channelMembersHash,
          dependencies: ChannelMembersFamily._dependencies,
          allTransitiveDependencies:
              ChannelMembersFamily._allTransitiveDependencies,
          guild: guild,
          channel: channel,
        );

  ChannelMembersProvider._internal(
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
  FutureOr<Pair<List<GuildMemberListGroup>, List<dynamic>>?> runNotifierBuild(
    covariant ChannelMembers notifier,
  ) {
    return notifier.build(
      guild,
      channel,
    );
  }

  @override
  Override overrideWith(ChannelMembers Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChannelMembersProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ChannelMembers,
      Pair<List<GuildMemberListGroup>, List<dynamic>>?> createElement() {
    return _ChannelMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelMembersProvider &&
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

mixin ChannelMembersRef on AutoDisposeAsyncNotifierProviderRef<
    Pair<List<GuildMemberListGroup>, List<dynamic>>?> {
  /// The parameter `guild` of this provider.
  Guild get guild;

  /// The parameter `channel` of this provider.
  Channel get channel;
}

class _ChannelMembersProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChannelMembers,
        Pair<List<GuildMemberListGroup>, List<dynamic>>?>
    with ChannelMembersRef {
  _ChannelMembersProviderElement(super.provider);

  @override
  Guild get guild => (origin as ChannelMembersProvider).guild;
  @override
  Channel get channel => (origin as ChannelMembersProvider).channel;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
