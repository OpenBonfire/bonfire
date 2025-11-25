// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_avatar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userAvatar)
const userAvatarProvider = UserAvatarFamily._();

final class UserAvatarProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>
        >
    with $FutureModifier<Uint8List?>, $FutureProvider<Uint8List?> {
  const UserAvatarProvider._({
    required UserAvatarFamily super.from,
    required User super.argument,
  }) : super(
         retry: null,
         name: r'userAvatarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userAvatarHash();

  @override
  String toString() {
    return r'userAvatarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List?> create(Ref ref) {
    final argument = this.argument as User;
    return userAvatar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserAvatarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userAvatarHash() => r'3982dfdca04e32dd6f5ac7d9ff30cf8acee5c319';

final class UserAvatarFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List?>, User> {
  const UserAvatarFamily._()
    : super(
        retry: null,
        name: r'userAvatarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserAvatarProvider call(User user) =>
      UserAvatarProvider._(argument: user, from: this);

  @override
  String toString() => r'userAvatarProvider';
}
