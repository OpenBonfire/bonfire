// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_posts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$forumPostsHash() => r'440ee92e5a0e1327ad51c50933436fc2497c8be5';

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

abstract class _$ForumPosts extends BuildlessAsyncNotifier<ThreadList?> {
  late final Snowflake channelId;

  FutureOr<ThreadList?> build(
    Snowflake channelId,
  );
}

/// Fetches a forum channel from the [channelId].
///
/// Copied from [ForumPosts].
@ProviderFor(ForumPosts)
const forumPostsProvider = ForumPostsFamily();

/// Fetches a forum channel from the [channelId].
///
/// Copied from [ForumPosts].
class ForumPostsFamily extends Family<AsyncValue<ThreadList?>> {
  /// Fetches a forum channel from the [channelId].
  ///
  /// Copied from [ForumPosts].
  const ForumPostsFamily();

  /// Fetches a forum channel from the [channelId].
  ///
  /// Copied from [ForumPosts].
  ForumPostsProvider call(
    Snowflake channelId,
  ) {
    return ForumPostsProvider(
      channelId,
    );
  }

  @override
  ForumPostsProvider getProviderOverride(
    covariant ForumPostsProvider provider,
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
  String? get name => r'forumPostsProvider';
}

/// Fetches a forum channel from the [channelId].
///
/// Copied from [ForumPosts].
class ForumPostsProvider
    extends AsyncNotifierProviderImpl<ForumPosts, ThreadList?> {
  /// Fetches a forum channel from the [channelId].
  ///
  /// Copied from [ForumPosts].
  ForumPostsProvider(
    Snowflake channelId,
  ) : this._internal(
          () => ForumPosts()..channelId = channelId,
          from: forumPostsProvider,
          name: r'forumPostsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$forumPostsHash,
          dependencies: ForumPostsFamily._dependencies,
          allTransitiveDependencies:
              ForumPostsFamily._allTransitiveDependencies,
          channelId: channelId,
        );

  ForumPostsProvider._internal(
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
  FutureOr<ThreadList?> runNotifierBuild(
    covariant ForumPosts notifier,
  ) {
    return notifier.build(
      channelId,
    );
  }

  @override
  Override overrideWith(ForumPosts Function() create) {
    return ProviderOverride(
      origin: this,
      override: ForumPostsProvider._internal(
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
  AsyncNotifierProviderElement<ForumPosts, ThreadList?> createElement() {
    return _ForumPostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ForumPostsProvider && other.channelId == channelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, channelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ForumPostsRef on AsyncNotifierProviderRef<ThreadList?> {
  /// The parameter `channelId` of this provider.
  Snowflake get channelId;
}

class _ForumPostsProviderElement
    extends AsyncNotifierProviderElement<ForumPosts, ThreadList?>
    with ForumPostsRef {
  _ForumPostsProviderElement(super.provider);

  @override
  Snowflake get channelId => (origin as ForumPostsProvider).channelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
