// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThreadChannel)
const threadChannelProvider = ThreadChannelFamily._();

final class ThreadChannelProvider
    extends $NotifierProvider<ThreadChannel, Channel?> {
  const ThreadChannelProvider._({
    required ThreadChannelFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'threadChannelProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$threadChannelHash();

  @override
  String toString() {
    return r'threadChannelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ThreadChannel create() => ThreadChannel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Channel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Channel?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ThreadChannelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$threadChannelHash() => r'978541d1e6c62409681e1ba9c38976ee410d7465';

final class ThreadChannelFamily extends $Family
    with
        $ClassFamilyOverride<
          ThreadChannel,
          Channel?,
          Channel?,
          Channel?,
          Snowflake
        > {
  const ThreadChannelFamily._()
    : super(
        retry: null,
        name: r'threadChannelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ThreadChannelProvider call(Snowflake channelId) =>
      ThreadChannelProvider._(argument: channelId, from: this);

  @override
  String toString() => r'threadChannelProvider';
}

abstract class _$ThreadChannel extends $Notifier<Channel?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get channelId => _$args;

  Channel? build(Snowflake channelId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<Channel?, Channel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Channel?, Channel?>,
              Channel?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(FirstMessage)
const firstMessageProvider = FirstMessageFamily._();

final class FirstMessageProvider
    extends $NotifierProvider<FirstMessage, Message?> {
  const FirstMessageProvider._({
    required FirstMessageFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'firstMessageProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$firstMessageHash();

  @override
  String toString() {
    return r'firstMessageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FirstMessage create() => FirstMessage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Message? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Message?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FirstMessageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$firstMessageHash() => r'df3012cc799a51760acb497c92f30cb47cdac767';

final class FirstMessageFamily extends $Family
    with
        $ClassFamilyOverride<
          FirstMessage,
          Message?,
          Message?,
          Message?,
          Snowflake
        > {
  const FirstMessageFamily._()
    : super(
        retry: null,
        name: r'firstMessageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  FirstMessageProvider call(Snowflake channelId) =>
      FirstMessageProvider._(argument: channelId, from: this);

  @override
  String toString() => r'firstMessageProvider';
}

abstract class _$FirstMessage extends $Notifier<Message?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get channelId => _$args;

  Message? build(Snowflake channelId);
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
