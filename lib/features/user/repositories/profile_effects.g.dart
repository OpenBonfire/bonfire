// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_effects.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileEffects)
const profileEffectsProvider = ProfileEffectsProvider._();

final class ProfileEffectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProfileEffectConfig>?>,
          List<ProfileEffectConfig>?,
          FutureOr<List<ProfileEffectConfig>?>
        >
    with
        $FutureModifier<List<ProfileEffectConfig>?>,
        $FutureProvider<List<ProfileEffectConfig>?> {
  const ProfileEffectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileEffectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileEffectsHash();

  @$internal
  @override
  $FutureProviderElement<List<ProfileEffectConfig>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProfileEffectConfig>?> create(Ref ref) {
    return profileEffects(ref);
  }
}

String _$profileEffectsHash() => r'ccff97b6cfa6372552cb058ab105fe541159040d';
