// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_connection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VoiceConnectionController)
final voiceConnectionControllerProvider = VoiceConnectionControllerProvider._();

final class VoiceConnectionControllerProvider
    extends $NotifierProvider<VoiceConnectionController, VoiceConnectionState> {
  VoiceConnectionControllerProvider._()
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
    r'3dc33e87503a2d8b7534ba1de424b20ed688b17d';

abstract class _$VoiceConnectionController
    extends $Notifier<VoiceConnectionState> {
  VoiceConnectionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VoiceConnectionState, VoiceConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoiceConnectionState, VoiceConnectionState>,
              VoiceConnectionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
