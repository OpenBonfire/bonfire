// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_icon.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roleIconHash() => r'dcaae7382243eb2d985902afd78df265fa040c39';

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

/// See also [roleIcon].
@ProviderFor(roleIcon)
const roleIconProvider = RoleIconFamily();

/// See also [roleIcon].
class RoleIconFamily extends Family<AsyncValue<Uint8List?>> {
  /// See also [roleIcon].
  const RoleIconFamily();

  /// See also [roleIcon].
  RoleIconProvider call(
    Snowflake guildId,
    Snowflake authorId,
  ) {
    return RoleIconProvider(
      guildId,
      authorId,
    );
  }

  @override
  RoleIconProvider getProviderOverride(
    covariant RoleIconProvider provider,
  ) {
    return call(
      provider.guildId,
      provider.authorId,
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
  String? get name => r'roleIconProvider';
}

/// See also [roleIcon].
class RoleIconProvider extends FutureProvider<Uint8List?> {
  /// See also [roleIcon].
  RoleIconProvider(
    Snowflake guildId,
    Snowflake authorId,
  ) : this._internal(
          (ref) => roleIcon(
            ref as RoleIconRef,
            guildId,
            authorId,
          ),
          from: roleIconProvider,
          name: r'roleIconProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roleIconHash,
          dependencies: RoleIconFamily._dependencies,
          allTransitiveDependencies: RoleIconFamily._allTransitiveDependencies,
          guildId: guildId,
          authorId: authorId,
        );

  RoleIconProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guildId,
    required this.authorId,
  }) : super.internal();

  final Snowflake guildId;
  final Snowflake authorId;

  @override
  Override overrideWith(
    FutureOr<Uint8List?> Function(RoleIconRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoleIconProvider._internal(
        (ref) => create(ref as RoleIconRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guildId: guildId,
        authorId: authorId,
      ),
    );
  }

  @override
  FutureProviderElement<Uint8List?> createElement() {
    return _RoleIconProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoleIconProvider &&
        other.guildId == guildId &&
        other.authorId == authorId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);
    hash = _SystemHash.combine(hash, authorId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RoleIconRef on FutureProviderRef<Uint8List?> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;

  /// The parameter `authorId` of this provider.
  Snowflake get authorId;
}

class _RoleIconProviderElement extends FutureProviderElement<Uint8List?>
    with RoleIconRef {
  _RoleIconProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as RoleIconProvider).guildId;
  @override
  Snowflake get authorId => (origin as RoleIconProvider).authorId;
}

String _$roleColorHash() => r'735194e67d8e6d63568b69368520e5d73d95e4b4';

/// See also [roleColor].
@ProviderFor(roleColor)
const roleColorProvider = RoleColorFamily();

/// See also [roleColor].
class RoleColorFamily extends Family<AsyncValue<Color>> {
  /// See also [roleColor].
  const RoleColorFamily();

  /// See also [roleColor].
  RoleColorProvider call(
    Snowflake guildId,
    Snowflake authorId,
  ) {
    return RoleColorProvider(
      guildId,
      authorId,
    );
  }

  @override
  RoleColorProvider getProviderOverride(
    covariant RoleColorProvider provider,
  ) {
    return call(
      provider.guildId,
      provider.authorId,
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
  String? get name => r'roleColorProvider';
}

/// See also [roleColor].
class RoleColorProvider extends AutoDisposeFutureProvider<Color> {
  /// See also [roleColor].
  RoleColorProvider(
    Snowflake guildId,
    Snowflake authorId,
  ) : this._internal(
          (ref) => roleColor(
            ref as RoleColorRef,
            guildId,
            authorId,
          ),
          from: roleColorProvider,
          name: r'roleColorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roleColorHash,
          dependencies: RoleColorFamily._dependencies,
          allTransitiveDependencies: RoleColorFamily._allTransitiveDependencies,
          guildId: guildId,
          authorId: authorId,
        );

  RoleColorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.guildId,
    required this.authorId,
  }) : super.internal();

  final Snowflake guildId;
  final Snowflake authorId;

  @override
  Override overrideWith(
    FutureOr<Color> Function(RoleColorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoleColorProvider._internal(
        (ref) => create(ref as RoleColorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        guildId: guildId,
        authorId: authorId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Color> createElement() {
    return _RoleColorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoleColorProvider &&
        other.guildId == guildId &&
        other.authorId == authorId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, guildId.hashCode);
    hash = _SystemHash.combine(hash, authorId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RoleColorRef on AutoDisposeFutureProviderRef<Color> {
  /// The parameter `guildId` of this provider.
  Snowflake get guildId;

  /// The parameter `authorId` of this provider.
  Snowflake get authorId;
}

class _RoleColorProviderElement extends AutoDisposeFutureProviderElement<Color>
    with RoleColorRef {
  _RoleColorProviderElement(super.provider);

  @override
  Snowflake get guildId => (origin as RoleColorProvider).guildId;
  @override
  Snowflake get authorId => (origin as RoleColorProvider).authorId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
