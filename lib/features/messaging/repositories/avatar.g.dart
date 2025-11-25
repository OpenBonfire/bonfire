// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memberAvatar)
const memberAvatarProvider = MemberAvatarFamily._();

final class MemberAvatarProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>
        >
    with $FutureModifier<Uint8List?>, $FutureProvider<Uint8List?> {
  const MemberAvatarProvider._({
    required MemberAvatarFamily super.from,
    required Member super.argument,
  }) : super(
         retry: null,
         name: r'memberAvatarProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberAvatarHash();

  @override
  String toString() {
    return r'memberAvatarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List?> create(Ref ref) {
    final argument = this.argument as Member;
    return memberAvatar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberAvatarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberAvatarHash() => r'a4284ceeacda6a715d122da2f161c5c94ccbd377';

final class MemberAvatarFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List?>, Member> {
  const MemberAvatarFamily._()
    : super(
        retry: null,
        name: r'memberAvatarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MemberAvatarProvider call(Member member) =>
      MemberAvatarProvider._(argument: member, from: this);

  @override
  String toString() => r'memberAvatarProvider';
}
