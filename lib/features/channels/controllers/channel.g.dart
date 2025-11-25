// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the current channel from the [channelid].

@ProviderFor(ChannelController)
const channelControllerProvider = ChannelControllerFamily._();

/// Fetches the current channel from the [channelid].
final class ChannelControllerProvider
    extends $NotifierProvider<ChannelController, Channel?> {
  /// Fetches the current channel from the [channelid].
  const ChannelControllerProvider._({
    required ChannelControllerFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'channelControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelControllerHash();

  @override
  String toString() {
    return r'channelControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChannelController create() => ChannelController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Channel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Channel?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelControllerHash() => r'58ed7419d86b9ba38ba3c18bd5b9f6b17f4bdc71';

/// Fetches the current channel from the [channelid].

final class ChannelControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChannelController,
          Channel?,
          Channel?,
          Channel?,
          Snowflake
        > {
  const ChannelControllerFamily._()
    : super(
        retry: null,
        name: r'channelControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Fetches the current channel from the [channelid].

  ChannelControllerProvider call(Snowflake channelId) =>
      ChannelControllerProvider._(argument: channelId, from: this);

  @override
  String toString() => r'channelControllerProvider';
}

/// Fetches the current channel from the [channelid].

abstract class _$ChannelController extends $Notifier<Channel?> {
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
