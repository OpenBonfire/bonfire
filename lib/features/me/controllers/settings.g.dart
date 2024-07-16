// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$privateMessageHistoryHash() =>
    r'1f5ec1fcc1b890b4e368564407dd70d05685a24b';

/// See also [PrivateMessageHistory].
@ProviderFor(PrivateMessageHistory)
final privateMessageHistoryProvider =
    NotifierProvider<PrivateMessageHistory, List<PrivateChannel>>.internal(
  PrivateMessageHistory.new,
  name: r'privateMessageHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$privateMessageHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PrivateMessageHistory = Notifier<List<PrivateChannel>>;
String _$guildFoldersHash() => r'7e8b9a3c50d1bbd5abf6f23f04c46b6a2ff674b3';

/// See also [GuildFolders].
@ProviderFor(GuildFolders)
final guildFoldersProvider =
    NotifierProvider<GuildFolders, List<GuildFolder>?>.internal(
  GuildFolders.new,
  name: r'guildFoldersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$guildFoldersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GuildFolders = Notifier<List<GuildFolder>?>;
String _$channelReadStateHash() => r'9b8a22ce3ab8d8a3f0eb9e6cf82936402624ff3e';

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

abstract class _$ChannelReadState extends BuildlessNotifier<ReadState?> {
  late final Snowflake channelId;

  ReadState? build(
    Snowflake channelId,
  );
}

/// See also [ChannelReadState].
@ProviderFor(ChannelReadState)
const channelReadStateProvider = ChannelReadStateFamily();

/// See also [ChannelReadState].
class ChannelReadStateFamily extends Family<ReadState?> {
  /// See also [ChannelReadState].
  const ChannelReadStateFamily();

  /// See also [ChannelReadState].
  ChannelReadStateProvider call(
    Snowflake channelId,
  ) {
    return ChannelReadStateProvider(
      channelId,
    );
  }

  @override
  ChannelReadStateProvider getProviderOverride(
    covariant ChannelReadStateProvider provider,
  ) {
    return call(
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
  String? get name => r'channelReadStateProvider';
}

/// See also [ChannelReadState].
class ChannelReadStateProvider
    extends NotifierProviderImpl<ChannelReadState, ReadState?> {
  /// See also [ChannelReadState].
  ChannelReadStateProvider(
    Snowflake channelId,
  ) : this._internal(
          () => ChannelReadState()..channelId = channelId,
          from: channelReadStateProvider,
          name: r'channelReadStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$channelReadStateHash,
          dependencies: ChannelReadStateFamily._dependencies,
          allTransitiveDependencies:
              ChannelReadStateFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  ChannelReadStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.channelId,
  }) : super.internal();

  final Snowflake channelId;

  @override
  ReadState? runNotifierBuild(
    covariant ChannelReadState notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(ChannelReadState Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChannelReadStateProvider._internal(
        () => create()..channelId = channelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        channelId: channelId,
      ),
    );
  }

  @override
  NotifierProviderElement<ChannelReadState, ReadState?> createElement() {
    return _ChannelReadStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelReadStateProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChannelReadStateRef on NotifierProviderRef<ReadState?> {
  /// The parameter `channelId` of this provider.
  Snowflake get channelId;
}

class _ChannelReadStateProviderElement
    extends NotifierProviderElement<ChannelReadState, ReadState?>
    with ChannelReadStateRef {
  _ChannelReadStateProviderElement(super.provider);

  @override
  Snowflake get channelId => (origin as ChannelReadStateProvider).channelId;
}

String _$userStatusStateHash() => r'dbf8e807d098cd9848dbdedba472d42243d1d490';

/// See also [UserStatusState].
@ProviderFor(UserStatusState)
final userStatusStateProvider =
    NotifierProvider<UserStatusState, UserStatus?>.internal(
  UserStatusState.new,
  name: r'userStatusStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userStatusStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserStatusState = Notifier<UserStatus?>;
String _$customStatusStateHash() => r'0714d50f94a66471c2715255ae77ebef99bc1641';

/// See also [CustomStatusState].
@ProviderFor(CustomStatusState)
final customStatusStateProvider =
    NotifierProvider<CustomStatusState, CustomStatus?>.internal(
  CustomStatusState.new,
  name: r'customStatusStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customStatusStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CustomStatusState = Notifier<CustomStatus?>;
String _$guildsStateHash() => r'cc23fc227059af452ebb927ee332ec09c10595a0';

/// See also [GuildsState].
@ProviderFor(GuildsState)
final guildsStateProvider =
    NotifierProvider<GuildsState, List<Guild>?>.internal(
  GuildsState.new,
  name: r'guildsStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$guildsStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GuildsState = Notifier<List<Guild>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
