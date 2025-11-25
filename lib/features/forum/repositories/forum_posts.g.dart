// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_posts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches a forum channel from the [channelId].

@ProviderFor(ForumPosts)
const forumPostsProvider = ForumPostsFamily._();

/// Fetches a forum channel from the [channelId].
final class ForumPostsProvider
    extends $AsyncNotifierProvider<ForumPosts, List<ThreadList?>> {
  /// Fetches a forum channel from the [channelId].
  const ForumPostsProvider._({
    required ForumPostsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'forumPostsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$forumPostsHash();

  @override
  String toString() {
    return r'forumPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ForumPosts create() => ForumPosts();

  @override
  bool operator ==(Object other) {
    return other is ForumPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$forumPostsHash() => r'47802c390bb8622fba3c74df3c21e49bd031096a';

/// Fetches a forum channel from the [channelId].

final class ForumPostsFamily extends $Family
    with
        $ClassFamilyOverride<
          ForumPosts,
          AsyncValue<List<ThreadList?>>,
          List<ThreadList?>,
          FutureOr<List<ThreadList?>>,
          Snowflake
        > {
  const ForumPostsFamily._()
    : super(
        retry: null,
        name: r'forumPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Fetches a forum channel from the [channelId].

  ForumPostsProvider call(Snowflake channelId) =>
      ForumPostsProvider._(argument: channelId, from: this);

  @override
  String toString() => r'forumPostsProvider';
}

/// Fetches a forum channel from the [channelId].

abstract class _$ForumPosts extends $AsyncNotifier<List<ThreadList?>> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get channelId => _$args;

  FutureOr<List<ThreadList?>> build(Snowflake channelId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<List<ThreadList?>>, List<ThreadList?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ThreadList?>>, List<ThreadList?>>,
              AsyncValue<List<ThreadList?>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
