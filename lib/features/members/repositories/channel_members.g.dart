// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_members.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GuildMemberList)
final guildMemberListProvider = GuildMemberListFamily._();

final class GuildMemberListProvider
    extends
        $AsyncNotifierProvider<
          GuildMemberList,
          Pair<List<GuildMemberListGroup>, List<dynamic>>
        > {
  GuildMemberListProvider._({
    required GuildMemberListFamily super.from,
    required Snowflake super.argument,
  }) : super(
         retry: null,
         name: r'guildMemberListProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guildMemberListHash();

  @override
  String toString() {
    return r'guildMemberListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GuildMemberList create() => GuildMemberList();

  @override
  bool operator ==(Object other) {
    return other is GuildMemberListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guildMemberListHash() => r'4d327b796ec3b7b57752b71f6da08fc2fef2b521';

final class GuildMemberListFamily extends $Family
    with
        $ClassFamilyOverride<
          GuildMemberList,
          AsyncValue<Pair<List<GuildMemberListGroup>, List<dynamic>>>,
          Pair<List<GuildMemberListGroup>, List<dynamic>>,
          FutureOr<Pair<List<GuildMemberListGroup>, List<dynamic>>>,
          Snowflake
        > {
  GuildMemberListFamily._()
    : super(
        retry: null,
        name: r'guildMemberListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GuildMemberListProvider call(Snowflake guildId) =>
      GuildMemberListProvider._(argument: guildId, from: this);

  @override
  String toString() => r'guildMemberListProvider';
}

abstract class _$GuildMemberList
    extends $AsyncNotifier<Pair<List<GuildMemberListGroup>, List<dynamic>>> {
  late final _$args = ref.$arg as Snowflake;
  Snowflake get guildId => _$args;

  FutureOr<Pair<List<GuildMemberListGroup>, List<dynamic>>> build(
    Snowflake guildId,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Pair<List<GuildMemberListGroup>, List<dynamic>>>,
              Pair<List<GuildMemberListGroup>, List<dynamic>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Pair<List<GuildMemberListGroup>, List<dynamic>>>,
                Pair<List<GuildMemberListGroup>, List<dynamic>>
              >,
              AsyncValue<Pair<List<GuildMemberListGroup>, List<dynamic>>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(ChannelMembers)
final channelMembersProvider = ChannelMembersProvider._();

final class ChannelMembersProvider
    extends
        $AsyncNotifierProvider<
          ChannelMembers,
          Pair<List<GuildMemberListGroup>, List<dynamic>>?
        > {
  ChannelMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'channelMembersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$channelMembersHash();

  @$internal
  @override
  ChannelMembers create() => ChannelMembers();
}

String _$channelMembersHash() => r'd36e8d8dae2e4bf3362a523b98b5bf0abb172213';

abstract class _$ChannelMembers
    extends $AsyncNotifier<Pair<List<GuildMemberListGroup>, List<dynamic>>?> {
  FutureOr<Pair<List<GuildMemberListGroup>, List<dynamic>>?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Pair<List<GuildMemberListGroup>, List<dynamic>>?>,
              Pair<List<GuildMemberListGroup>, List<dynamic>>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Pair<List<GuildMemberListGroup>, List<dynamic>>?>,
                Pair<List<GuildMemberListGroup>, List<dynamic>>?
              >,
              AsyncValue<Pair<List<GuildMemberListGroup>, List<dynamic>>?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
