// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChannelMessages)
const channelMessagesProvider = ChannelMessagesFamily._();

final class ChannelMessagesProvider
    extends $AsyncNotifierProvider<ChannelMessages, List<Message>> {
  const ChannelMessagesProvider._({
    required ChannelMessagesFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'channelMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelMessagesHash();

  @override
  String toString() {
    return r'channelMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChannelMessages create() => ChannelMessages();

  @override
  bool operator ==(Object other) {
    return other is ChannelMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelMessagesHash() => r'4e6968cb029cb5842e9f70e2a944ac0cd2825929';

final class ChannelMessagesFamily extends $Family
    with
        $ClassFamilyOverride<
          ChannelMessages,
          AsyncValue<List<Message>>,
          List<Message>,
          FutureOr<List<Message>>,
          Snowflake
        > {
  const ChannelMessagesFamily._()
    : super(
        retry: null,
        name: r'channelMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChannelMessagesProvider call(Snowflake channelId) =>
      ChannelMessagesProvider._(argument: channelId, from: this);

  @override
  String toString() => r'channelMessagesProvider';
}

abstract class _$ChannelMessages extends $AsyncNotifier<List<Message>> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get channelId => _$args;

  FutureOr<List<Message>> build(Snowflake channelId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<Message>>, List<Message>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Message>>, List<Message>>,
              AsyncValue<List<Message>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
