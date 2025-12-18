// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guild_mentions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GuildMentions)
const guildMentionsProvider = GuildMentionsFamily._();

final class GuildMentionsProvider
    extends $AsyncNotifierProvider<GuildMentions, int> {
  const GuildMentionsProvider._({
    required GuildMentionsFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'guildMentionsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guildMentionsHash();

  @override
  String toString() {
    return r'guildMentionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GuildMentions create() => GuildMentions();

  @override
  bool operator ==(Object other) {
    return other is GuildMentionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guildMentionsHash() => r'4b80b418c8afc416a3f6b40aa6693a5b2c354426';

final class GuildMentionsFamily extends $Family
    with
        $ClassFamilyOverride<
          GuildMentions,
          AsyncValue<int>,
          int,
          FutureOr<int>,
          Snowflake
        > {
  const GuildMentionsFamily._()
    : super(
        retry: null,
        name: r'guildMentionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GuildMentionsProvider call(Snowflake guildId) =>
      GuildMentionsProvider._(argument: guildId, from: this);

  @override
  String toString() => r'guildMentionsProvider';
}

abstract class _$GuildMentions extends $AsyncNotifier<int> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get guildId => _$args;

  FutureOr<int> build(Snowflake guildId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
