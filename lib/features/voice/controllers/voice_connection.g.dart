// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_connection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VoiceConnectionController)
const voiceConnectionControllerProvider = VoiceConnectionControllerProvider._();

final class VoiceConnectionControllerProvider
    extends $NotifierProvider<VoiceConnectionController, VoiceConnectionState> {
  const VoiceConnectionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voiceConnectionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voiceConnectionControllerHash();

  @$internal
  @override
  VoiceConnectionController create() => VoiceConnectionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoiceConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoiceConnectionState>(value),
    );
  }
}

String _$voiceConnectionControllerHash() =>
    r'f2c78161c2be2c9f7a5cf198758899ee7d591e6c';

abstract class _$VoiceConnectionController
    extends $Notifier<VoiceConnectionState> {
  VoiceConnectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<VoiceConnectionState, VoiceConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoiceConnectionState, VoiceConnectionState>,
              VoiceConnectionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
