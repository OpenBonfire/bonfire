// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PrivateMessageHistory)
const privateMessageHistoryProvider = PrivateMessageHistoryProvider._();

final class PrivateMessageHistoryProvider
    extends $NotifierProvider<PrivateMessageHistory, List<Channel>> {
  const PrivateMessageHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'privateMessageHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$privateMessageHistoryHash();

  @$internal
  @override
  PrivateMessageHistory create() => PrivateMessageHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Channel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Channel>>(value),
    );
  }
}

String _$privateMessageHistoryHash() =>
    r'91c24e817e66bb683e97ccff3355693d37152f88';

abstract class _$PrivateMessageHistory extends $Notifier<List<Channel>> {
  List<Channel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Channel>, List<Channel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Channel>, List<Channel>>,
              List<Channel>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(GuildFolders)
const guildFoldersProvider = GuildFoldersProvider._();

final class GuildFoldersProvider
    extends $NotifierProvider<GuildFolders, List<GuildFolder>?> {
  const GuildFoldersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guildFoldersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guildFoldersHash();

  @$internal
  @override
  GuildFolders create() => GuildFolders();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<GuildFolder>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<GuildFolder>?>(value),
    );
  }
}

String _$guildFoldersHash() => r'7e8b9a3c50d1bbd5abf6f23f04c46b6a2ff674b3';

abstract class _$GuildFolders extends $Notifier<List<GuildFolder>?> {
  List<GuildFolder>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<GuildFolder>?, List<GuildFolder>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<GuildFolder>?, List<GuildFolder>?>,
              List<GuildFolder>?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChannelReadState)
const channelReadStateProvider = ChannelReadStateFamily._();

final class ChannelReadStateProvider
    extends $NotifierProvider<ChannelReadState, ReadState?> {
  const ChannelReadStateProvider._({
    required ChannelReadStateFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'channelReadStateProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelReadStateHash();

  @override
  String toString() {
    return r'channelReadStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChannelReadState create() => ChannelReadState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadState?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelReadStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelReadStateHash() => r'9b8a22ce3ab8d8a3f0eb9e6cf82936402624ff3e';

final class ChannelReadStateFamily extends $Family
    with
        $ClassFamilyOverride<
          ChannelReadState,
          ReadState?,
          ReadState?,
          ReadState?,
          Snowflake
        > {
  const ChannelReadStateFamily._()
    : super(
        retry: null,
        name: r'channelReadStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ChannelReadStateProvider call(Snowflake channelId) =>
      ChannelReadStateProvider._(argument: channelId, from: this);

  @override
  String toString() => r'channelReadStateProvider';
}

abstract class _$ChannelReadState extends $Notifier<ReadState?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get channelId => _$args;

  ReadState? build(Snowflake channelId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ReadState?, ReadState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReadState?, ReadState?>,
              ReadState?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelfStatusState)
const selfStatusStateProvider = SelfStatusStateProvider._();

final class SelfStatusStateProvider
    extends $NotifierProvider<SelfStatusState, UserStatus?> {
  const SelfStatusStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selfStatusStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selfStatusStateHash();

  @$internal
  @override
  SelfStatusState create() => SelfStatusState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserStatus?>(value),
    );
  }
}

String _$selfStatusStateHash() => r'642153c17c0cbf0edd6896182602bc8f1812aa55';

abstract class _$SelfStatusState extends $Notifier<UserStatus?> {
  UserStatus? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserStatus?, UserStatus?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserStatus?, UserStatus?>,
              UserStatus?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(UserStatusState)
const userStatusStateProvider = UserStatusStateFamily._();

final class UserStatusStateProvider
    extends $NotifierProvider<UserStatusState, UserStatus?> {
  const UserStatusStateProvider._({
    required UserStatusStateFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'userStatusStateProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userStatusStateHash();

  @override
  String toString() {
    return r'userStatusStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserStatusState create() => UserStatusState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserStatus?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserStatusStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userStatusStateHash() => r'1b0f5660c34b3cf5b0e754ef98f9f6285a4f4431';

final class UserStatusStateFamily extends $Family
    with
        $ClassFamilyOverride<
          UserStatusState,
          UserStatus?,
          UserStatus?,
          UserStatus?,
          Snowflake
        > {
  const UserStatusStateFamily._()
    : super(
        retry: null,
        name: r'userStatusStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  UserStatusStateProvider call(Snowflake userId) =>
      UserStatusStateProvider._(argument: userId, from: this);

  @override
  String toString() => r'userStatusStateProvider';
}

abstract class _$UserStatusState extends $Notifier<UserStatus?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get userId => _$args;

  UserStatus? build(Snowflake userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<UserStatus?, UserStatus?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserStatus?, UserStatus?>,
              UserStatus?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(UserActivityState)
const userActivityStateProvider = UserActivityStateFamily._();

final class UserActivityStateProvider
    extends $NotifierProvider<UserActivityState, List<Activity>?> {
  const UserActivityStateProvider._({
    required UserActivityStateFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'userActivityStateProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userActivityStateHash();

  @override
  String toString() {
    return r'userActivityStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserActivityState create() => UserActivityState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Activity>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Activity>?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserActivityStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userActivityStateHash() => r'3433c5a0f492a7ca3104bda404168b080c3d339e';

final class UserActivityStateFamily extends $Family
    with
        $ClassFamilyOverride<
          UserActivityState,
          List<Activity>?,
          List<Activity>?,
          List<Activity>?,
          Snowflake
        > {
  const UserActivityStateFamily._()
    : super(
        retry: null,
        name: r'userActivityStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  UserActivityStateProvider call(Snowflake userId) =>
      UserActivityStateProvider._(argument: userId, from: this);

  @override
  String toString() => r'userActivityStateProvider';
}

abstract class _$UserActivityState extends $Notifier<List<Activity>?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get userId => _$args;

  List<Activity>? build(Snowflake userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<List<Activity>?, List<Activity>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Activity>?, List<Activity>?>,
              List<Activity>?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CustomStatusState)
const customStatusStateProvider = CustomStatusStateProvider._();

final class CustomStatusStateProvider
    extends $NotifierProvider<CustomStatusState, CustomStatus?> {
  const CustomStatusStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customStatusStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customStatusStateHash();

  @$internal
  @override
  CustomStatusState create() => CustomStatusState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomStatus?>(value),
    );
  }
}

String _$customStatusStateHash() => r'0714d50f94a66471c2715255ae77ebef99bc1641';

abstract class _$CustomStatusState extends $Notifier<CustomStatus?> {
  CustomStatus? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CustomStatus?, CustomStatus?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CustomStatus?, CustomStatus?>,
              CustomStatus?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
