// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channels.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A riverpod provider that fetches the channels for the current guild.

@ProviderFor(Channels)
const channelsProvider = ChannelsFamily._();

/// A riverpod provider that fetches the channels for the current guild.
final class ChannelsProvider
    extends $AsyncNotifierProvider<Channels, List<Channel>> {
  /// A riverpod provider that fetches the channels for the current guild.
  const ChannelsProvider._({
    required ChannelsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'channelsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelsHash();

  @override
  String toString() {
    return r'channelsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Channels create() => Channels();

  @override
  bool operator ==(Object other) {
    return other is ChannelsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelsHash() => r'dae41d5d8bf0ff8c3e6aa1042d8b54c74f4d7c40';

/// A riverpod provider that fetches the channels for the current guild.

final class ChannelsFamily extends $Family
    with
        $ClassFamilyOverride<
          Channels,
          AsyncValue<List<Channel>>,
          List<Channel>,
          FutureOr<List<Channel>>,
          Snowflake
        > {
  const ChannelsFamily._()
    : super(
        retry: null,
        name: r'channelsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// A riverpod provider that fetches the channels for the current guild.

  ChannelsProvider call(Snowflake guildId) =>
      ChannelsProvider._(argument: guildId, from: this);

  @override
  String toString() => r'channelsProvider';
}

/// A riverpod provider that fetches the channels for the current guild.

abstract class _$Channels extends $AsyncNotifier<List<Channel>> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get guildId => _$args;

  FutureOr<List<Channel>> build(Snowflake guildId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<Channel>>, List<Channel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Channel>>, List<Channel>>,
              AsyncValue<List<Channel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
