// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guilds.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Guilds)
const guildsProvider = GuildsProvider._();

final class GuildsProvider
    extends $AsyncNotifierProvider<Guilds, List<UserGuild>> {
  const GuildsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guildsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guildsHash();

  @$internal
  @override
  Guilds create() => Guilds();
}

String _$guildsHash() => r'8ca6033da6980cbc6f043cff0421526667fed5f5';

abstract class _$Guilds extends $AsyncNotifier<List<UserGuild>> {
  FutureOr<List<UserGuild>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<UserGuild>>, List<UserGuild>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<UserGuild>>, List<UserGuild>>,
              AsyncValue<List<UserGuild>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
