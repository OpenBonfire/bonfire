// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VoiceChannelController)
const voiceChannelControllerProvider = VoiceChannelControllerProvider._();

final class VoiceChannelControllerProvider
    extends $NotifierProvider<VoiceChannelController, VoiceReadyEvent?> {
  const VoiceChannelControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voiceChannelControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voiceChannelControllerHash();

  @$internal
  @override
  VoiceChannelController create() => VoiceChannelController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoiceReadyEvent? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoiceReadyEvent?>(value),
    );
  }
}

String _$voiceChannelControllerHash() =>
    r'e60429b62cfcee23a5fb71529a75b2c36bd17aa6';

abstract class _$VoiceChannelController extends $Notifier<VoiceReadyEvent?> {
  VoiceReadyEvent? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<VoiceReadyEvent?, VoiceReadyEvent?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoiceReadyEvent?, VoiceReadyEvent?>,
              VoiceReadyEvent?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
