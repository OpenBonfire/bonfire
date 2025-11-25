// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_list_width.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChannelListWidth)
const channelListWidthProvider = ChannelListWidthProvider._();

final class ChannelListWidthProvider
    extends $NotifierProvider<ChannelListWidth, int> {
  const ChannelListWidthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'channelListWidthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$channelListWidthHash();

  @$internal
  @override
  ChannelListWidth create() => ChannelListWidth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$channelListWidthHash() => r'9c9bae30cc1eeea6c033715467a36e1540901e28';

abstract class _$ChannelListWidth extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
