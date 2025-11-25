// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MessageController)
const messageControllerProvider = MessageControllerFamily._();

final class MessageControllerProvider
    extends $NotifierProvider<MessageController, Message?> {
  const MessageControllerProvider._({
    required MessageControllerFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'messageControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messageControllerHash();

  @override
  String toString() {
    return r'messageControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MessageController create() => MessageController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Message? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Message?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MessageControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messageControllerHash() => r'b2e02f7c2ea0369d4e95ac40065ea811d0259b6b';

final class MessageControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MessageController,
          Message?,
          Message?,
          Message?,
          Snowflake
        > {
  const MessageControllerFamily._()
    : super(
        retry: null,
        name: r'messageControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MessageControllerProvider call(Snowflake messageId) =>
      MessageControllerProvider._(argument: messageId, from: this);

  @override
  String toString() => r'messageControllerProvider';
}

abstract class _$MessageController extends $Notifier<Message?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get messageId => _$args;

  Message? build(Snowflake messageId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<Message?, Message?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Message?, Message?>,
              Message?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
