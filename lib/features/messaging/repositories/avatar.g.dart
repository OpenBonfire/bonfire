// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memberAvatarHash() => r'134560332234e005fcfa6a36ceee2413324a3f73';

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

/// See also [memberAvatar].
@ProviderFor(memberAvatar)
const memberAvatarProvider = MemberAvatarFamily();

/// See also [memberAvatar].
class MemberAvatarFamily extends Family<AsyncValue<Uint8List?>> {
  /// See also [memberAvatar].
  const MemberAvatarFamily();

  /// See also [memberAvatar].
  MemberAvatarProvider call(
    Member member,
  ) {
    return MemberAvatarProvider(
      member,
    );
  }

  @override
  MemberAvatarProvider getProviderOverride(
    covariant MemberAvatarProvider provider,
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
  String? get name => r'memberAvatarProvider';
}

/// See also [memberAvatar].
class MemberAvatarProvider extends FutureProvider<Uint8List?> {
  /// See also [memberAvatar].
  MemberAvatarProvider(
    Member member,
  ) : this._internal(
          (ref) => memberAvatar(
            ref as MemberAvatarRef,
            member,
          ),
          from: memberAvatarProvider,
          name: r'memberAvatarProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$memberAvatarHash,
          dependencies: MemberAvatarFamily._dependencies,
          allTransitiveDependencies:
              MemberAvatarFamily._allTransitiveDependencies,
          member: member,
        );

  MemberAvatarProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.member,
  }) : super.internal();

  final Member member;

  @override
  Override overrideWith(
    FutureOr<Uint8List?> Function(MemberAvatarRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MemberAvatarProvider._internal(
        (ref) => create(ref as MemberAvatarRef),
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
  FutureProviderElement<Uint8List?> createElement() {
    return _MemberAvatarProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberAvatarProvider && other.member == member;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, member.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MemberAvatarRef on FutureProviderRef<Uint8List?> {
  /// The parameter `member` of this provider.
  Member get member;
}

class _MemberAvatarProviderElement extends FutureProviderElement<Uint8List?>
    with MemberAvatarRef {
  _MemberAvatarProviderElement(super.provider);

  @override
  Member get member => (origin as MemberAvatarProvider).member;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
