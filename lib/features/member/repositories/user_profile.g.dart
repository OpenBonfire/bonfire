// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserProfileController)
const userProfileControllerProvider = UserProfileControllerFamily._();

final class UserProfileControllerProvider
    extends $AsyncNotifierProvider<UserProfileController, UserProfile?> {
  const UserProfileControllerProvider._({
    required UserProfileControllerFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'userProfileControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userProfileControllerHash();

  @override
  String toString() {
    return r'userProfileControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserProfileController create() => UserProfileController();

  @override
  bool operator ==(Object other) {
    return other is UserProfileControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileControllerHash() =>
    r'aa8bd1f1b4e0e83da326430f2e6c0223177b2799';

final class UserProfileControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          UserProfileController,
          AsyncValue<UserProfile?>,
          UserProfile?,
          FutureOr<UserProfile?>,
          Snowflake
        > {
  const UserProfileControllerFamily._()
    : super(
        retry: null,
        name: r'userProfileControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  UserProfileControllerProvider call(Snowflake userId) =>
      UserProfileControllerProvider._(argument: userId, from: this);

  @override
  String toString() => r'userProfileControllerProvider';
}

abstract class _$UserProfileController extends $AsyncNotifier<UserProfile?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get userId => _$args;

  FutureOr<UserProfile?> build(Snowflake userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<UserProfile?>, UserProfile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfile?>, UserProfile?>,
              AsyncValue<UserProfile?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
