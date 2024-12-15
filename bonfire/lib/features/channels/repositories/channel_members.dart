import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/shared/models/pair.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'channel_members.g.dart';

@Riverpod(keepAlive: true)
class GuildMemberList extends _$GuildMemberList {
  Pair<List<GuildMemberListGroup>, List<dynamic>>? _data;

  @override
  Future<Pair<List<GuildMemberListGroup>, List<dynamic>>> build(
      Snowflake guildId) async {
    return _data!;
  }

  void setData(
    Snowflake channelId,
    Pair<List<GuildMemberListGroup>, List<dynamic>> newData,
  ) {
    _data = newData;
    state = AsyncValue.data(_data!);
  }
}

@Riverpod(keepAlive: true)
class ChannelMembers extends _$ChannelMembers {
  AuthUser? user;
  Snowflake guildId = Snowflake.zero;
  Snowflake channelId = Snowflake.zero;
  // Map<Snowflake, Pair<List<GuildMemberListGroup>, List<dynamic>>>
  //     subscriptionCache = {};
  List<GuildSubscriptionChannel> currentSubscriptions = [];

  @override
  Future<Pair<List<GuildMemberListGroup>, List<dynamic>>?> build() async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    if (authOutput is AuthUser) {
      user = authOutput;
    }

    return null;
  }

  void setRoute(Snowflake guildId, Snowflake channelId) async {
    this.guildId = guildId;
    this.channelId = channelId;
    currentSubscriptions = [
      GuildSubscriptionChannel(
        channelId: channelId,
        memberRange: GuildMemberRange(
          lowerMemberBound: 0,
          upperMemberBound: 99,
        ),
      )
    ];
    _updateSubscriptions();
  }

  void loadMemberRange(int lowerBound, int upperBound) {
    currentSubscriptions.add(GuildSubscriptionChannel(
      channelId: channelId,
      memberRange: GuildMemberRange(
        lowerMemberBound: lowerBound,
        upperMemberBound: upperBound,
      ),
    ));
    _updateSubscriptions();
  }

  void _updateSubscriptions() {
    if (user is AuthUser) {
      user!.client.updateGuildSubscriptionsBulk(GuildSubscriptionsBulkBuilder()
        ..subscriptions = [
          GuildSubscription(
              typing: true,
              memberUpdates: true,
              channels: currentSubscriptions,
              guildId: guildId)
        ]);
    }
  }

  void updateMemberList(
    List<dynamic> memberList,
    List<GuildMemberListGroup> groups,
    Snowflake guildId,
  ) {
    var pair = Pair(groups, memberList);
    ref
        .watch(guildMemberListProvider(guildId).notifier)
        .setData(channelId, pair);

    state = AsyncValue.data(pair);
  }
}
