// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MessageSearch)
const messageSearchProvider = MessageSearchFamily._();

final class MessageSearchProvider
    extends $AsyncNotifierProvider<MessageSearch, List<Message>?> {
  const MessageSearchProvider._({
    required MessageSearchFamily super.from,
    required (Snowflake, String) super.argument,
  }) : super(
         retry: null,
         name: r'messageSearchProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messageSearchHash();

  @override
  String toString() {
    return r'messageSearchProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MessageSearch create() => MessageSearch();

  @override
  bool operator ==(Object other) {
    return other is MessageSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageSearchHash() => r'a75733bb3a64f68f7d0b6c69288398dd3afb7280';

final class MessageSearchFamily extends $Family
    with
        $ClassFamilyOverride<
          MessageSearch,
          AsyncValue<List<Message>?>,
          List<Message>?,
          FutureOr<List<Message>?>,
          (Snowflake, String)
        > {
  const MessageSearchFamily._()
    : super(
        retry: null,
        name: r'messageSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MessageSearchProvider call(Snowflake guildId, String query) =>
      MessageSearchProvider._(argument: (guildId, query), from: this);

  @override
  String toString() => r'messageSearchProvider';
}

abstract class _$MessageSearch extends $AsyncNotifier<List<Message>?> {
  late final _$args = ref.$arg as (Snowflake, String);
  Snowflake get guildId => _$args.$1;
  String get query => _$args.$2;

  FutureOr<List<Message>?> build(Snowflake guildId, String query);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, _$args.$2);
    final ref = this.ref as $Ref<AsyncValue<List<Message>?>, List<Message>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Message>?>, List<Message>?>,
              AsyncValue<List<Message>?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
