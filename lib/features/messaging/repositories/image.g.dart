// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachedImageHash() => r'b60e7477de6e6dd4c2c4454462db11192edcada1';

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

/// See also [attachedImage].
@ProviderFor(attachedImage)
const attachedImageProvider = AttachedImageFamily();

/// See also [attachedImage].
class AttachedImageFamily extends Family<AsyncValue<Uint8List?>> {
  /// See also [attachedImage].
  const AttachedImageFamily();

  /// See also [attachedImage].
  AttachedImageProvider call(
    Attachment attachment,
  ) {
    return AttachedImageProvider(
      attachment,
    );
  }

  @override
  AttachedImageProvider getProviderOverride(
    covariant AttachedImageProvider provider,
  ) {
    return call(
      provider.attachment,
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
  String? get name => r'attachedImageProvider';
}

/// See also [attachedImage].
class AttachedImageProvider extends FutureProvider<Uint8List?> {
  /// See also [attachedImage].
  AttachedImageProvider(
    Attachment attachment,
  ) : this._internal(
          (ref) => attachedImage(
            ref as AttachedImageRef,
            attachment,
          ),
          from: attachedImageProvider,
          name: r'attachedImageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$attachedImageHash,
          dependencies: AttachedImageFamily._dependencies,
          allTransitiveDependencies:
              AttachedImageFamily._allTransitiveDependencies,
          attachment: attachment,
        );

  AttachedImageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.attachment,
  }) : super.internal();

  final Attachment attachment;

  @override
  Override overrideWith(
    FutureOr<Uint8List?> Function(AttachedImageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AttachedImageProvider._internal(
        (ref) => create(ref as AttachedImageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        attachment: attachment,
      ),
    );
  }

  @override
  FutureProviderElement<Uint8List?> createElement() {
    return _AttachedImageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttachedImageProvider && other.attachment == attachment;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, attachment.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AttachedImageRef on FutureProviderRef<Uint8List?> {
  /// The parameter `attachment` of this provider.
  Attachment get attachment;
}

class _AttachedImageProviderElement extends FutureProviderElement<Uint8List?>
    with AttachedImageRef {
  _AttachedImageProviderElement(super.provider);

  @override
  Attachment get attachment => (origin as AttachedImageProvider).attachment;
}

String _$embeddedImageHash() => r'4c09866299b75f220247de855d7a62a5575e31aa';

/// See also [embeddedImage].
@ProviderFor(embeddedImage)
const embeddedImageProvider = EmbeddedImageFamily();

/// See also [embeddedImage].
class EmbeddedImageFamily extends Family<AsyncValue<Uint8List?>> {
  /// See also [embeddedImage].
  const EmbeddedImageFamily();

  /// See also [embeddedImage].
  EmbeddedImageProvider call(
    Embed embed,
  ) {
    return EmbeddedImageProvider(
      embed,
    );
  }

  @override
  EmbeddedImageProvider getProviderOverride(
    covariant EmbeddedImageProvider provider,
  ) {
    return call(
      provider.embed,
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
  String? get name => r'embeddedImageProvider';
}

/// See also [embeddedImage].
class EmbeddedImageProvider extends AutoDisposeFutureProvider<Uint8List?> {
  /// See also [embeddedImage].
  EmbeddedImageProvider(
    Embed embed,
  ) : this._internal(
          (ref) => embeddedImage(
            ref as EmbeddedImageRef,
            embed,
          ),
          from: embeddedImageProvider,
          name: r'embeddedImageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$embeddedImageHash,
          dependencies: EmbeddedImageFamily._dependencies,
          allTransitiveDependencies:
              EmbeddedImageFamily._allTransitiveDependencies,
          embed: embed,
        );

  EmbeddedImageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.embed,
  }) : super.internal();

  final Embed embed;

  @override
  Override overrideWith(
    FutureOr<Uint8List?> Function(EmbeddedImageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EmbeddedImageProvider._internal(
        (ref) => create(ref as EmbeddedImageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        embed: embed,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Uint8List?> createElement() {
    return _EmbeddedImageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EmbeddedImageProvider && other.embed == embed;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, embed.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EmbeddedImageRef on AutoDisposeFutureProviderRef<Uint8List?> {
  /// The parameter `embed` of this provider.
  Embed get embed;
}

class _EmbeddedImageProviderElement
    extends AutoDisposeFutureProviderElement<Uint8List?> with EmbeddedImageRef {
  _EmbeddedImageProviderElement(super.provider);

  @override
  Embed get embed => (origin as EmbeddedImageProvider).embed;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
