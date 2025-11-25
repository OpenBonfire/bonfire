// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guilds.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the current guild from [guildid].

@ProviderFor(GuildsController)
const guildsControllerProvider = GuildsControllerProvider._();

/// Fetches the current guild from [guildid].
final class GuildsControllerProvider
    extends $NotifierProvider<GuildsController, List<Guild>?> {
  /// Fetches the current guild from [guildid].
  const GuildsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guildsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guildsControllerHash();

  @$internal
  @override
  GuildsController create() => GuildsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Guild>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Guild>?>(value),
    );
  }
}

String _$guildsControllerHash() => r'1fbe9d3a66dc3ee4e40d6b022d82ee10194e21e3';

/// Fetches the current guild from [guildid].

abstract class _$GuildsController extends $Notifier<List<Guild>?> {
  List<Guild>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Guild>?, List<Guild>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Guild>?, List<Guild>?>,
              List<Guild>?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
