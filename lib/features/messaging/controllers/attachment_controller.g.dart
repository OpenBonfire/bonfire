// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentVideoControllerHash() =>
    r'90e9527e2d7eb1bd1a89e2c69fe800347e34b2a9';

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

/// See also [attachmentVideoController].
@ProviderFor(attachmentVideoController)
const attachmentVideoControllerProvider = AttachmentVideoControllerFamily();

/// See also [attachmentVideoController].
class AttachmentVideoControllerFamily extends Family<VideoController?> {
  /// See also [attachmentVideoController].
  const AttachmentVideoControllerFamily();

  /// See also [attachmentVideoController].
  AttachmentVideoControllerProvider call(
    String url,
  ) {
    return AttachmentVideoControllerProvider(
      url,
    );
  }

  @override
  AttachmentVideoControllerProvider getProviderOverride(
    covariant AttachmentVideoControllerProvider provider,
  ) {
    return call(
      provider.url,
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
  String? get name => r'attachmentVideoControllerProvider';
}

/// See also [attachmentVideoController].
class AttachmentVideoControllerProvider
    extends AutoDisposeProvider<VideoController?> {
  /// See also [attachmentVideoController].
  AttachmentVideoControllerProvider(
    String url,
  ) : this._internal(
          (ref) => attachmentVideoController(
            ref as AttachmentVideoControllerRef,
            url,
          ),
          from: attachmentVideoControllerProvider,
          name: r'attachmentVideoControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$attachmentVideoControllerHash,
          dependencies: AttachmentVideoControllerFamily._dependencies,
          allTransitiveDependencies:
              AttachmentVideoControllerFamily._allTransitiveDependencies,
          url: url,
        );

  AttachmentVideoControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
  }) : super.internal();

  final String url;

  @override
  Override overrideWith(
    VideoController? Function(AttachmentVideoControllerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AttachmentVideoControllerProvider._internal(
        (ref) => create(ref as AttachmentVideoControllerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        url: url,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<VideoController?> createElement() {
    return _AttachmentVideoControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttachmentVideoControllerProvider && other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AttachmentVideoControllerRef on AutoDisposeProviderRef<VideoController?> {
  /// The parameter `url` of this provider.
  String get url;
}

class _AttachmentVideoControllerProviderElement
    extends AutoDisposeProviderElement<VideoController?>
    with AttachmentVideoControllerRef {
  _AttachmentVideoControllerProviderElement(super.provider);

  @override
  String get url => (origin as AttachmentVideoControllerProvider).url;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
