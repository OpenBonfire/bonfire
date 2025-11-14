// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'has_unreads.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasUnreadsHash() => r'8b5f4c1c68d105aa86af102dc1530107ad5c5a1b';

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

abstract class _$HasUnreads extends BuildlessAsyncNotifier<bool> {
  late final Snowflake channelId;

  FutureOr<bool> build(
    Snowflake channelId,
  );
}

/// See also [HasUnreads].
@ProviderFor(HasUnreads)
const hasUnreadsProvider = HasUnreadsFamily();

/// See also [HasUnreads].
class HasUnreadsFamily extends Family<AsyncValue<bool>> {
  /// See also [HasUnreads].
  const HasUnreadsFamily();

  /// See also [HasUnreads].
  HasUnreadsProvider call(
    Snowflake channelId,
  ) {
    return HasUnreadsProvider(
      channelId,
    );
  }

  @override
  HasUnreadsProvider getProviderOverride(
    covariant HasUnreadsProvider provider,
  ) {
    return call(
      provider.channelId,
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
  String? get name => r'hasUnreadsProvider';
}

/// See also [HasUnreads].
class HasUnreadsProvider extends AsyncNotifierProviderImpl<HasUnreads, bool> {
  /// See also [HasUnreads].
  HasUnreadsProvider(
    Snowflake channelId,
  ) : this._internal(
          () => HasUnreads()..channelId = channelId,
          from: hasUnreadsProvider,
          name: r'hasUnreadsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hasUnreadsHash,
          dependencies: HasUnreadsFamily._dependencies,
          allTransitiveDependencies:
              HasUnreadsFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  HasUnreadsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.channelId,
  }) : super.internal();

  final Snowflake channelId;

  @override
  FutureOr<bool> runNotifierBuild(
    covariant HasUnreads notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(HasUnreads Function() create) {
    return ProviderOverride(
      origin: this,
      override: HasUnreadsProvider._internal(
        () => create()..channelId = channelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        channelId: channelId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<HasUnreads, bool> createElement() {
    return _HasUnreadsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasUnreadsProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HasUnreadsRef on AsyncNotifierProviderRef<bool> {
  /// The parameter `channelId` of this provider.
  Snowflake get channelId;
}

class _HasUnreadsProviderElement
    extends AsyncNotifierProviderElement<HasUnreads, bool> with HasUnreadsRef {
  _HasUnreadsProviderElement(super.provider);

  @override
  Snowflake get channelId => (origin as HasUnreadsProvider).channelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
