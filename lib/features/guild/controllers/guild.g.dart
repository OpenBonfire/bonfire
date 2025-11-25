// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the current guild from [guildid].

@ProviderFor(GuildController)
const guildControllerProvider = GuildControllerFamily._();

/// Fetches the current guild from [guildid].
final class GuildControllerProvider
    extends $NotifierProvider<GuildController, Guild?> {
  /// Fetches the current guild from [guildid].
  const GuildControllerProvider._({
    required GuildControllerFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'guildControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guildControllerHash();

  @override
  String toString() {
    return r'guildControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GuildController create() => GuildController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Guild? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Guild?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GuildControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guildControllerHash() => r'1d07c57a0de36bbe057044d5d21dbbff446388ba';

/// Fetches the current guild from [guildid].

final class GuildControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          GuildController,
          Guild?,
          Guild?,
          Guild?,
          Snowflake
        > {
  const GuildControllerFamily._()
    : super(
        retry: null,
        name: r'guildControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Fetches the current guild from [guildid].

  GuildControllerProvider call(Snowflake guildId) =>
      GuildControllerProvider._(argument: guildId, from: this);

  @override
  String toString() => r'guildControllerProvider';
}

/// Fetches the current guild from [guildid].

abstract class _$GuildController extends $Notifier<Guild?> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get guildId => _$args;

  Guild? build(Snowflake guildId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<Guild?, Guild?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Guild?, Guild?>,
              Guild?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
