// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(attachedImage)
const attachedImageProvider = AttachedImageFamily._();

final class AttachedImageProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>
        >
    with $FutureModifier<Uint8List?>, $FutureProvider<Uint8List?> {
  const AttachedImageProvider._({
    required AttachedImageFamily super.from,
    required Attachment super.argument,
  }) : super(
         retry: null,
         name: r'attachedImageProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attachedImageHash();

  @override
  String toString() {
    return r'attachedImageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List?> create(Ref ref) {
    final argument = this.argument as Attachment;
    return attachedImage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AttachedImageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attachedImageHash() => r'9d63fb6b1e3fee17c786dde2d44ad83678938161';

final class AttachedImageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List?>, Attachment> {
  const AttachedImageFamily._()
    : super(
        retry: null,
        name: r'attachedImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  AttachedImageProvider call(Attachment attachment) =>
      AttachedImageProvider._(argument: attachment, from: this);

  @override
  String toString() => r'attachedImageProvider';
}

@ProviderFor(embeddedImage)
const embeddedImageProvider = EmbeddedImageFamily._();

final class EmbeddedImageProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>
        >
    with $FutureModifier<Uint8List?>, $FutureProvider<Uint8List?> {
  const EmbeddedImageProvider._({
    required EmbeddedImageFamily super.from,
    required Embed super.argument,
  }) : super(
         retry: null,
         name: r'embeddedImageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$embeddedImageHash();

  @override
  String toString() {
    return r'embeddedImageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List?> create(Ref ref) {
    final argument = this.argument as Embed;
    return embeddedImage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EmbeddedImageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$embeddedImageHash() => r'e7d9c894f522c096cfe24370ddb90a55b5e509f3';

final class EmbeddedImageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List?>, Embed> {
  const EmbeddedImageFamily._()
    : super(
        retry: null,
        name: r'embeddedImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EmbeddedImageProvider call(Embed embed) =>
      EmbeddedImageProvider._(argument: embed, from: this);

  @override
  String toString() => r'embeddedImageProvider';
}
