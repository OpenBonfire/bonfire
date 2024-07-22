// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageAuthorAvatarHash() =>
    r'f7137171fba75b801285cc42ceb220f1dc053363';

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

/// See also [messageAuthorAvatar].
@ProviderFor(messageAuthorAvatar)
const messageAuthorAvatarProvider = MessageAuthorAvatarFamily();

/// See also [messageAuthorAvatar].
class MessageAuthorAvatarFamily extends Family<AsyncValue<Uint8List?>> {
  /// See also [messageAuthorAvatar].
  const MessageAuthorAvatarFamily();

  /// See also [messageAuthorAvatar].
  MessageAuthorAvatarProvider call(
    MessageAuthor member,
  ) {
    return MessageAuthorAvatarProvider(
      member,
    );
  }

  @override
  MessageAuthorAvatarProvider getProviderOverride(
    covariant MessageAuthorAvatarProvider provider,
  ) {
    return call(
      provider.member,
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
  String? get name => r'messageAuthorAvatarProvider';
}

/// See also [messageAuthorAvatar].
class MessageAuthorAvatarProvider
    extends AutoDisposeFutureProvider<Uint8List?> {
  /// See also [messageAuthorAvatar].
  MessageAuthorAvatarProvider(
    MessageAuthor member,
  ) : this._internal(
          (ref) => messageAuthorAvatar(
            ref as MessageAuthorAvatarRef,
            member,
          ),
          from: messageAuthorAvatarProvider,
          name: r'messageAuthorAvatarProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messageAuthorAvatarHash,
          dependencies: MessageAuthorAvatarFamily._dependencies,
          allTransitiveDependencies:
              MessageAuthorAvatarFamily._allTransitiveDependencies,
          member: member,
        );

  MessageAuthorAvatarProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.member,
  }) : super.internal();

  final MessageAuthor member;

  @override
  Override overrideWith(
    FutureOr<Uint8List?> Function(MessageAuthorAvatarRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageAuthorAvatarProvider._internal(
        (ref) => create(ref as MessageAuthorAvatarRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        member: member,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Uint8List?> createElement() {
    return _MessageAuthorAvatarProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageAuthorAvatarProvider && other.member == member;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, member.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MessageAuthorAvatarRef on AutoDisposeFutureProviderRef<Uint8List?> {
  /// The parameter `member` of this provider.
  MessageAuthor get member;
}

class _MessageAuthorAvatarProviderElement
    extends AutoDisposeFutureProviderElement<Uint8List?>
    with MessageAuthorAvatarRef {
  _MessageAuthorAvatarProviderElement(super.provider);

  @override
  MessageAuthor get member => (origin as MessageAuthorAvatarProvider).member;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
