// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'has_unreads.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasUnreadsHash() => r'd85c5a9db0cb730e8f5c42fe2a4b6d62967dc119';

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
  late final Channel channel;

  FutureOr<bool> build(
    Channel channel,
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
    Channel channel,
  ) {
    return HasUnreadsProvider(
      channel,
    );
  }

  @override
  HasUnreadsProvider getProviderOverride(
    covariant HasUnreadsProvider provider,
  ) {
    return call(
      provider.channel,
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
    Channel channel,
  ) : this._internal(
          () => HasUnreads()..channel = channel,
          from: hasUnreadsProvider,
          name: r'hasUnreadsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hasUnreadsHash,
          dependencies: HasUnreadsFamily._dependencies,
          allTransitiveDependencies:
              HasUnreadsFamily._allTransitiveDependencies,
          channel: channel,
        );

  HasUnreadsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.channel,
  }) : super.internal();

  final Channel channel;

  @override
  FutureOr<bool> runNotifierBuild(
    covariant HasUnreads notifier,
  ) {
    return notifier.build(
      channel,
    );
  }

  @override
  Override overrideWith(HasUnreads Function() create) {
    return ProviderOverride(
      origin: this,
      override: HasUnreadsProvider._internal(
        () => create()..channel = channel,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        channel: channel,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<HasUnreads, bool> createElement() {
    return _HasUnreadsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasUnreadsProvider && other.channel == channel;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channel.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin HasUnreadsRef on AsyncNotifierProviderRef<bool> {
  /// The parameter `channel` of this provider.
  Channel get channel;
}

class _HasUnreadsProviderElement
    extends AsyncNotifierProviderElement<HasUnreads, bool> with HasUnreadsRef {
  _HasUnreadsProviderElement(super.provider);

  @override
  Channel get channel => (origin as HasUnreadsProvider).channel;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
