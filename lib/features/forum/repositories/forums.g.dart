// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forums.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$forumsHash() => r'94028d3084f8a0de0827f26c5d7cd37ece2ac8fe';

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

abstract class _$Forums extends BuildlessAsyncNotifier<ForumChannel?> {
  late final Snowflake channelId;

  FutureOr<ForumChannel?> build(
    Snowflake channelId,
  );
}

/// Fetches a forum channel from the [channelId].
///
/// Copied from [Forums].
@ProviderFor(Forums)
const forumsProvider = ForumsFamily();

/// Fetches a forum channel from the [channelId].
///
/// Copied from [Forums].
class ForumsFamily extends Family<AsyncValue<ForumChannel?>> {
  /// Fetches a forum channel from the [channelId].
  ///
  /// Copied from [Forums].
  const ForumsFamily();

  /// Fetches a forum channel from the [channelId].
  ///
  /// Copied from [Forums].
  ForumsProvider call(
    Snowflake channelId,
  ) {
    return ForumsProvider(
      channelId,
    );
  }

  @override
  ForumsProvider getProviderOverride(
    covariant ForumsProvider provider,
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
  String? get name => r'forumsProvider';
}

/// Fetches a forum channel from the [channelId].
///
/// Copied from [Forums].
class ForumsProvider extends AsyncNotifierProviderImpl<Forums, ForumChannel?> {
  /// Fetches a forum channel from the [channelId].
  ///
  /// Copied from [Forums].
  ForumsProvider(
    Snowflake channelId,
  ) : this._internal(
          () => Forums()..channelId = channelId,
          from: forumsProvider,
          name: r'forumsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$forumsHash,
          dependencies: ForumsFamily._dependencies,
          allTransitiveDependencies: ForumsFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  ForumsProvider._internal(
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
  FutureOr<ForumChannel?> runNotifierBuild(
    covariant Forums notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(Forums Function() create) {
    return ProviderOverride(
      origin: this,
      override: ForumsProvider._internal(
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
  AsyncNotifierProviderElement<Forums, ForumChannel?> createElement() {
    return _ForumsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ForumsProvider && other.channelId == channelId;
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
mixin ForumsRef on AsyncNotifierProviderRef<ForumChannel?> {
  /// The parameter `channelId` of this provider.
  Snowflake get channelId;
}

class _ForumsProviderElement
    extends AsyncNotifierProviderElement<Forums, ForumChannel?> with ForumsRef {
  _ForumsProviderElement(super.provider);

  @override
  Snowflake get channelId => (origin as ForumsProvider).channelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
