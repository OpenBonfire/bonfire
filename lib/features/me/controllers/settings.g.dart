// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$privateMessageHistoryHash() =>
    r'91c24e817e66bb683e97ccff3355693d37152f88';

/// See also [PrivateMessageHistory].
@ProviderFor(PrivateMessageHistory)
final privateMessageHistoryProvider =
    NotifierProvider<PrivateMessageHistory, List<Channel>>.internal(
  PrivateMessageHistory.new,
  name: r'privateMessageHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$privateMessageHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PrivateMessageHistory = Notifier<List<Channel>>;
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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
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

String _$selfStatusStateHash() => r'642153c17c0cbf0edd6896182602bc8f1812aa55';

/// See also [SelfStatusState].
@ProviderFor(SelfStatusState)
final selfStatusStateProvider =
    NotifierProvider<SelfStatusState, UserStatus?>.internal(
  SelfStatusState.new,
  name: r'selfStatusStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selfStatusStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelfStatusState = Notifier<UserStatus?>;
String _$userStatusStateHash() => r'1b0f5660c34b3cf5b0e754ef98f9f6285a4f4431';

abstract class _$UserStatusState extends BuildlessNotifier<UserStatus?> {
  late final Snowflake userId;

  UserStatus? build(
    Snowflake userId,
  );
}

/// See also [UserStatusState].
@ProviderFor(UserStatusState)
const userStatusStateProvider = UserStatusStateFamily();

/// See also [UserStatusState].
class UserStatusStateFamily extends Family<UserStatus?> {
  /// See also [UserStatusState].
  const UserStatusStateFamily();

  /// See also [UserStatusState].
  UserStatusStateProvider call(
    Snowflake userId,
  ) {
    return UserStatusStateProvider(
      userId,
    );
  }

  @override
  UserStatusStateProvider getProviderOverride(
    covariant UserStatusStateProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'userStatusStateProvider';
}

/// See also [UserStatusState].
class UserStatusStateProvider
    extends NotifierProviderImpl<UserStatusState, UserStatus?> {
  /// See also [UserStatusState].
  UserStatusStateProvider(
    Snowflake userId,
  ) : this._internal(
          () => UserStatusState()..userId = userId,
          from: userStatusStateProvider,
          name: r'userStatusStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userStatusStateHash,
          dependencies: UserStatusStateFamily._dependencies,
          allTransitiveDependencies:
              UserStatusStateFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserStatusStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final Snowflake userId;

  @override
  UserStatus? runNotifierBuild(
    covariant UserStatusState notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(UserStatusState Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserStatusStateProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  NotifierProviderElement<UserStatusState, UserStatus?> createElement() {
    return _UserStatusStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserStatusStateProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserStatusStateRef on NotifierProviderRef<UserStatus?> {
  /// The parameter `userId` of this provider.
  Snowflake get userId;
}

class _UserStatusStateProviderElement
    extends NotifierProviderElement<UserStatusState, UserStatus?>
    with UserStatusStateRef {
  _UserStatusStateProviderElement(super.provider);

  @override
  Snowflake get userId => (origin as UserStatusStateProvider).userId;
}

String _$userActivityStateHash() => r'3433c5a0f492a7ca3104bda404168b080c3d339e';

abstract class _$UserActivityState extends BuildlessNotifier<List<Activity>?> {
  late final Snowflake userId;

  List<Activity>? build(
    Snowflake userId,
  );
}

/// See also [UserActivityState].
@ProviderFor(UserActivityState)
const userActivityStateProvider = UserActivityStateFamily();

/// See also [UserActivityState].
class UserActivityStateFamily extends Family<List<Activity>?> {
  /// See also [UserActivityState].
  const UserActivityStateFamily();

  /// See also [UserActivityState].
  UserActivityStateProvider call(
    Snowflake userId,
  ) {
    return UserActivityStateProvider(
      userId,
    );
  }

  @override
  UserActivityStateProvider getProviderOverride(
    covariant UserActivityStateProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'userActivityStateProvider';
}

/// See also [UserActivityState].
class UserActivityStateProvider
    extends NotifierProviderImpl<UserActivityState, List<Activity>?> {
  /// See also [UserActivityState].
  UserActivityStateProvider(
    Snowflake userId,
  ) : this._internal(
          () => UserActivityState()..userId = userId,
          from: userActivityStateProvider,
          name: r'userActivityStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userActivityStateHash,
          dependencies: UserActivityStateFamily._dependencies,
          allTransitiveDependencies:
              UserActivityStateFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserActivityStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final Snowflake userId;

  @override
  List<Activity>? runNotifierBuild(
    covariant UserActivityState notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(UserActivityState Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserActivityStateProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  NotifierProviderElement<UserActivityState, List<Activity>?> createElement() {
    return _UserActivityStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserActivityStateProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserActivityStateRef on NotifierProviderRef<List<Activity>?> {
  /// The parameter `userId` of this provider.
  Snowflake get userId;
}

class _UserActivityStateProviderElement
    extends NotifierProviderElement<UserActivityState, List<Activity>?>
    with UserActivityStateRef {
  _UserActivityStateProviderElement(super.provider);

  @override
  Snowflake get userId => (origin as UserActivityStateProvider).userId;
}

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
