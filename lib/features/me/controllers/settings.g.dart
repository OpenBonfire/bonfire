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
