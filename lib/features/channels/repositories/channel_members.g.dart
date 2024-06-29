// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_members.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$channelMembersHash() => r'bcd14b12a6039ab41fe89982f6619e2bb0c0bf65';

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

abstract class _$ChannelMembers extends BuildlessAsyncNotifier<
    Pair<List<GuildMemberListGroup>, List<dynamic>>?> {
  late final Snowflake guildId;
  late final Snowflake channelId;

  FutureOr<Pair<List<GuildMemberListGroup>, List<dynamic>>?> build(
    Snowflake guildId,
    Snowflake channelId,
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
    Snowflake guildId,
    Snowflake channelId,
  ) {
    return ChannelMembersProvider(
      guildId,
      channelId,
    );
  }

  @override
  ChannelMembersProvider getProviderOverride(
    covariant ChannelMembersProvider provider,
  ) {
    return call(
      provider.guildId,
      provider.channelId,
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
class ChannelMembersProvider extends AsyncNotifierProviderImpl<ChannelMembers,
    Pair<List<GuildMemberListGroup>, List<dynamic>>?> {
  /// See also [ChannelMembers].
  ChannelMembersProvider(
    Snowflake guildId,
    Snowflake channelId,
  ) : this._internal(
          () => ChannelMembers()
            ..guildId = guildId
            ..channelId = channelId,
          from: channelMembersProvider,
          name: r'channelMembersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$channelMembersHash,
          dependencies: ChannelMembersFamily._dependencies,
          allTransitiveDependencies:
              ChannelMembersFamily._allTransitiveDependencies,
          guildId: guildId,
          channelId: channelId,
        );

  ChannelMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guildId,
    required this.channelId,
  }) : super.internal();

  final Snowflake guildId;
  final Snowflake channelId;

  @override
  FutureOr<Pair<List<GuildMemberListGroup>, List<dynamic>>?> runNotifierBuild(
    covariant ChannelMembers notifier,
  ) {
    return notifier.build(
      guildId,
      channelId,
    );
  }

  @override
  Override overrideWith(ChannelMembers Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChannelMembersProvider._internal(
        () => create()
          ..guildId = guildId
          ..channelId = channelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guildId: guildId,
        channelId: channelId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<ChannelMembers,
      Pair<List<GuildMemberListGroup>, List<dynamic>>?> createElement() {
    return _ChannelMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelMembersProvider &&
        other.guildId == guildId &&
        other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChannelMembersRef on AsyncNotifierProviderRef<
    Pair<List<GuildMemberListGroup>, List<dynamic>>?> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;

  /// The parameter `channelId` of this provider.
  Snowflake get channelId;
}

class _ChannelMembersProviderElement extends AsyncNotifierProviderElement<
    ChannelMembers,
    Pair<List<GuildMemberListGroup>, List<dynamic>>?> with ChannelMembersRef {
  _ChannelMembersProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as ChannelMembersProvider).guildId;
  @override
  Snowflake get channelId => (origin as ChannelMembersProvider).channelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
