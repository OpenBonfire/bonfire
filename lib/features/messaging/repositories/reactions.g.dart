// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reactions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MessageReactions)
const messageReactionsProvider = MessageReactionsFamily._();

final class MessageReactionsProvider
    extends $NotifierProvider<MessageReactions, List<Reaction>?> {
  const MessageReactionsProvider._({
    required MessageReactionsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'messageReactionsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messageReactionsHash();

  @override
  String toString() {
    return r'messageReactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MessageReactions create() => MessageReactions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Reaction>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Reaction>?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessageReactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageReactionsHash() => r'eafaa7e5653f630accd9b2b54f313305102a899c';

final class MessageReactionsFamily extends $Family
    with
        $ClassFamilyOverride<
          MessageReactions,
          List<Reaction>?,
          List<Reaction>?,
          List<Reaction>?,
          Snowflake
        > {
  const MessageReactionsFamily._()
    : super(
        retry: null,
        name: r'messageReactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MessageReactionsProvider call(Snowflake messageId) =>
      MessageReactionsProvider._(argument: messageId, from: this);

  @override
  String toString() => r'messageReactionsProvider';
}

abstract class _$MessageReactions extends $Notifier<List<Reaction>?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get messageId => _$args;

  List<Reaction>? build(Snowflake messageId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<List<Reaction>?, List<Reaction>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Reaction>?, List<Reaction>?>,
              List<Reaction>?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
