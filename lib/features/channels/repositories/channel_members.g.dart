// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_members.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guildMemberListHash() => r'65dd141a6f9a43d7bedcd2a4fad84b53b3345d22';

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

abstract class _$GuildMemberList extends BuildlessAsyncNotifier<
    Pair<List<GuildMemberListGroup>, List<dynamic>>> {
  late final Snowflake guildId;

  FutureOr<Pair<List<GuildMemberListGroup>, List<dynamic>>> build(
    Snowflake guildId,
  );
}

/// See also [GuildMemberList].
@ProviderFor(GuildMemberList)
const guildMemberListProvider = GuildMemberListFamily();

/// See also [GuildMemberList].
class GuildMemberListFamily extends Family<
    AsyncValue<Pair<List<GuildMemberListGroup>, List<dynamic>>>> {
  /// See also [GuildMemberList].
  const GuildMemberListFamily();

  /// See also [GuildMemberList].
  GuildMemberListProvider call(
    Snowflake guildId,
  ) {
    return GuildMemberListProvider(
      guildId,
    );
  }

  @override
  GuildMemberListProvider getProviderOverride(
    covariant GuildMemberListProvider provider,
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
  String? get name => r'guildMemberListProvider';
}

/// See also [GuildMemberList].
class GuildMemberListProvider extends AsyncNotifierProviderImpl<GuildMemberList,
    Pair<List<GuildMemberListGroup>, List<dynamic>>> {
  /// See also [GuildMemberList].
  GuildMemberListProvider(
    Snowflake guildId,
  ) : this._internal(
          () => GuildMemberList()..guildId = guildId,
          from: guildMemberListProvider,
          name: r'guildMemberListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$guildMemberListHash,
          dependencies: GuildMemberListFamily._dependencies,
          allTransitiveDependencies:
              GuildMemberListFamily._allTransitiveDependencies,
          guildId: guildId,
        );

  GuildMemberListProvider._internal(
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
  FutureOr<Pair<List<GuildMemberListGroup>, List<dynamic>>> runNotifierBuild(
    covariant GuildMemberList notifier,
  ) {
    return notifier.build(
      guildId,
    );
  }

  @override
  Override overrideWith(GuildMemberList Function() create) {
    return ProviderOverride(
      origin: this,
      override: GuildMemberListProvider._internal(
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
  AsyncNotifierProviderElement<GuildMemberList,
      Pair<List<GuildMemberListGroup>, List<dynamic>>> createElement() {
    return _GuildMemberListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GuildMemberListProvider && other.guildId == guildId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GuildMemberListRef on AsyncNotifierProviderRef<
    Pair<List<GuildMemberListGroup>, List<dynamic>>> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;
}

class _GuildMemberListProviderElement extends AsyncNotifierProviderElement<
    GuildMemberList,
    Pair<List<GuildMemberListGroup>, List<dynamic>>> with GuildMemberListRef {
  _GuildMemberListProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as GuildMemberListProvider).guildId;
}

String _$channelMembersHash() => r'8422e527836f57e3b298a44d5c265cd3723cb8cf';

/// See also [ChannelMembers].
@ProviderFor(ChannelMembers)
final channelMembersProvider = AsyncNotifierProvider<ChannelMembers,
    Pair<List<GuildMemberListGroup>, List<dynamic>>?>.internal(
  ChannelMembers.new,
  name: r'channelMembersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$channelMembersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChannelMembers
    = AsyncNotifier<Pair<List<GuildMemberListGroup>, List<dynamic>>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
