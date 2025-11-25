// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Message provider for fetching messages from the Discord API

@ProviderFor(Messages)
const messagesProvider = MessagesFamily._();

/// Message provider for fetching messages from the Discord API
final class MessagesProvider
    extends $AsyncNotifierProvider<Messages, List<Message>?> {
  /// Message provider for fetching messages from the Discord API
  const MessagesProvider._({
    required MessagesFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'messagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messagesHash();

  @override
  String toString() {
    return r'messagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Messages create() => Messages();

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messagesHash() => r'bec23ec95d31ab3675c3001aedaa23759f4432af';

/// Message provider for fetching messages from the Discord API

final class MessagesFamily extends $Family
    with
        $ClassFamilyOverride<
          Messages,
          AsyncValue<List<Message>?>,
          List<Message>?,
          FutureOr<List<Message>?>,
          Snowflake
        > {
  const MessagesFamily._()
    : super(
        retry: null,
        name: r'messagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Message provider for fetching messages from the Discord API

  MessagesProvider call(Snowflake channelId) =>
      MessagesProvider._(argument: channelId, from: this);

  @override
  String toString() => r'messagesProvider';
}

/// Message provider for fetching messages from the Discord API

abstract class _$Messages extends $AsyncNotifier<List<Message>?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get channelId => _$args;

  FutureOr<List<Message>?> build(Snowflake channelId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
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
