// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserController)
const userControllerProvider = UserControllerFamily._();

final class UserControllerProvider
    extends $NotifierProvider<UserController, User?> {
  const UserControllerProvider._({
    required UserControllerFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'userControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userControllerHash();

  @override
  String toString() {
    return r'userControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserController create() => UserController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userControllerHash() => r'ed579518bea5be24ee9459a8ff7e8d1b70894c31';

final class UserControllerFamily extends $Family
    with $ClassFamilyOverride<UserController, User?, User?, User?, Snowflake> {
  const UserControllerFamily._()
    : super(
        retry: null,
        name: r'userControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  UserControllerProvider call(Snowflake userId) =>
      UserControllerProvider._(argument: userId, from: this);

  @override
  String toString() => r'userControllerProvider';
}

abstract class _$UserController extends $Notifier<User?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get userId => _$args;

  User? build(Snowflake userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<User?, User?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<User?, User?>,
              User?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
