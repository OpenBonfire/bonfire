// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_icon.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Get the icon of a given user by id

@ProviderFor(UserIcon)
const userIconProvider = UserIconFamily._();

/// Get the icon of a given user by id
final class UserIconProvider
    extends $AsyncNotifierProvider<UserIcon, Uint8List?> {
  /// Get the icon of a given user by id
  const UserIconProvider._({
    required UserIconFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'userIconProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userIconHash();

  @override
  String toString() {
    return r'userIconProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserIcon create() => UserIcon();

  @override
  bool operator ==(Object other) {
    return other is UserIconProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userIconHash() => r'93bfe9b4c7d6d140a29387d0838501ea95ef650c';

/// Get the icon of a given user by id

final class UserIconFamily extends $Family
    with
        $ClassFamilyOverride<
          UserIcon,
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>,
          Snowflake
        > {
  const UserIconFamily._()
    : super(
        retry: null,
        name: r'userIconProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Get the icon of a given user by id

  UserIconProvider call(Snowflake userId) =>
      UserIconProvider._(argument: userId, from: this);

  @override
  String toString() => r'userIconProvider';
}

/// Get the icon of a given user by id

abstract class _$UserIcon extends $AsyncNotifier<Uint8List?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get userId => _$args;

  FutureOr<Uint8List?> build(Snowflake userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<Uint8List?>, Uint8List?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Uint8List?>, Uint8List?>,
              AsyncValue<Uint8List?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
