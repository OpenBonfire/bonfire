// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(messageAuthorAvatar)
const messageAuthorAvatarProvider = MessageAuthorAvatarFamily._();

final class MessageAuthorAvatarProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>
        >
    with $FutureModifier<Uint8List?>, $FutureProvider<Uint8List?> {
  const MessageAuthorAvatarProvider._({
    required MessageAuthorAvatarFamily super.from,
    required MessageAuthor super.argument,
  }) : super(
         retry: null,
         name: r'messageAuthorAvatarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messageAuthorAvatarHash();

  @override
  String toString() {
    return r'messageAuthorAvatarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List?> create(Ref ref) {
    final argument = this.argument as MessageAuthor;
    return messageAuthorAvatar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageAuthorAvatarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageAuthorAvatarHash() =>
    r'f28aacf08d50928e35167e7f6dc0492a4b15a4be';

final class MessageAuthorAvatarFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List?>, MessageAuthor> {
  const MessageAuthorAvatarFamily._()
    : super(
        retry: null,
        name: r'messageAuthorAvatarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MessageAuthorAvatarProvider call(MessageAuthor member) =>
      MessageAuthorAvatarProvider._(argument: member, from: this);

  @override
  String toString() => r'messageAuthorAvatarProvider';
}
