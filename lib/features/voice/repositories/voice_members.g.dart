// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_members.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VoiceMembers)
const voiceMembersProvider = VoiceMembersFamily._();

final class VoiceMembersProvider
    extends
        $AsyncNotifierProvider<
          VoiceMembers,
          List<MapEntry<Snowflake, VoiceState>>?
        > {
  const VoiceMembersProvider._({
    required VoiceMembersFamily super.from,
    required (Snowflake, {Snowflake? channelId}) super.argument,
  }) : super(
         retry: null,
         name: r'voiceMembersProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$voiceMembersHash();

  @override
  String toString() {
    return r'voiceMembersProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  VoiceMembers create() => VoiceMembers();

  @override
  bool operator ==(Object other) {
    return other is VoiceMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$voiceMembersHash() => r'586b94445c2cb8b060fbc399ec246aca48694531';

final class VoiceMembersFamily extends $Family
    with
        $ClassFamilyOverride<
          VoiceMembers,
          AsyncValue<List<MapEntry<Snowflake, VoiceState>>?>,
          List<MapEntry<Snowflake, VoiceState>>?,
          FutureOr<List<MapEntry<Snowflake, VoiceState>>?>,
          (Snowflake, {Snowflake? channelId})
        > {
  const VoiceMembersFamily._()
    : super(
        retry: null,
        name: r'voiceMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  VoiceMembersProvider call(Snowflake guildId, {Snowflake? channelId}) =>
      VoiceMembersProvider._(
        argument: (guildId, channelId: channelId),
        from: this,
      );

  @override
  String toString() => r'voiceMembersProvider';
}

abstract class _$VoiceMembers
    extends $AsyncNotifier<List<MapEntry<Snowflake, VoiceState>>?> {
  late final _$args = ref.$arg as (Snowflake, {Snowflake? channelId});
  Snowflake get guildId => _$args.$1;
  Snowflake? get channelId => _$args.channelId;

  FutureOr<List<MapEntry<Snowflake, VoiceState>>?> build(
    Snowflake guildId, {
    Snowflake? channelId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, channelId: _$args.channelId);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MapEntry<Snowflake, VoiceState>>?>,
              List<MapEntry<Snowflake, VoiceState>>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MapEntry<Snowflake, VoiceState>>?>,
                List<MapEntry<Snowflake, VoiceState>>?
              >,
              AsyncValue<List<MapEntry<Snowflake, VoiceState>>?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
