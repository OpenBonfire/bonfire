// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_unreads.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GuildUnreads)
const guildUnreadsProvider = GuildUnreadsFamily._();

final class GuildUnreadsProvider
    extends $AsyncNotifierProvider<GuildUnreads, bool> {
  const GuildUnreadsProvider._({
    required GuildUnreadsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'guildUnreadsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guildUnreadsHash();

  @override
  String toString() {
    return r'guildUnreadsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GuildUnreads create() => GuildUnreads();

  @override
  bool operator ==(Object other) {
    return other is GuildUnreadsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guildUnreadsHash() => r'8c1e502d39136de914e8c0a09b9fef501fd17228';

final class GuildUnreadsFamily extends $Family
    with
        $ClassFamilyOverride<
          GuildUnreads,
          AsyncValue<bool>,
          bool,
          FutureOr<bool>,
          Snowflake
        > {
  const GuildUnreadsFamily._()
    : super(
        retry: null,
        name: r'guildUnreadsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GuildUnreadsProvider call(Snowflake guildId) =>
      GuildUnreadsProvider._(argument: guildId, from: this);

  @override
  String toString() => r'guildUnreadsProvider';
}

abstract class _$GuildUnreads extends $AsyncNotifier<bool> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get guildId => _$args;

  FutureOr<bool> build(Snowflake guildId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
