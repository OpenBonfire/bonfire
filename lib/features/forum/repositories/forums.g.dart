// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forums.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches a forum channel from the [channelId].

@ProviderFor(Forums)
const forumsProvider = ForumsFamily._();

/// Fetches a forum channel from the [channelId].
final class ForumsProvider
    extends $AsyncNotifierProvider<Forums, ForumChannel?> {
  /// Fetches a forum channel from the [channelId].
  const ForumsProvider._({
    required ForumsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'forumsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$forumsHash();

  @override
  String toString() {
    return r'forumsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Forums create() => Forums();

  @override
  bool operator ==(Object other) {
    return other is ForumsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$forumsHash() => r'94028d3084f8a0de0827f26c5d7cd37ece2ac8fe';

/// Fetches a forum channel from the [channelId].

final class ForumsFamily extends $Family
    with
        $ClassFamilyOverride<
          Forums,
          AsyncValue<ForumChannel?>,
          ForumChannel?,
          FutureOr<ForumChannel?>,
          Snowflake
        > {
  const ForumsFamily._()
    : super(
        retry: null,
        name: r'forumsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Fetches a forum channel from the [channelId].

  ForumsProvider call(Snowflake channelId) =>
      ForumsProvider._(argument: channelId, from: this);

  @override
  String toString() => r'forumsProvider';
}

/// Fetches a forum channel from the [channelId].

abstract class _$Forums extends $AsyncNotifier<ForumChannel?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get channelId => _$args;

  FutureOr<ForumChannel?> build(Snowflake channelId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<ForumChannel?>, ForumChannel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ForumChannel?>, ForumChannel?>,
              AsyncValue<ForumChannel?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
