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
String _$channelReadStateHash() => r'79e53110fa491c507f7b17038fb9b5ae7bd6592b';

/// See also [ChannelReadState].
@ProviderFor(ChannelReadState)
final channelReadStateProvider =
    NotifierProvider<ChannelReadState, Map<Snowflake, ReadState>?>.internal(
  ChannelReadState.new,
  name: r'channelReadStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$channelReadStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChannelReadState = Notifier<Map<Snowflake, ReadState>?>;
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
