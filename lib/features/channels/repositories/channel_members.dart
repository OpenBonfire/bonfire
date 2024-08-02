import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/shared/models/pair.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'channel_members.g.dart';

@Riverpod(keepAlive: true)
class ChannelMembers extends _$ChannelMembers {
  AuthUser? user;
  Snowflake guildId = Snowflake.zero;
  Snowflake channelId = Snowflake.zero;
  Pair<List<GuildMemberListGroup>, List<dynamic>>? lastPair;
  List<GuildSubscriptionChannel> currentSubscriptions = [];

  @override
  Future<Pair<List<GuildMemberListGroup>, List<dynamic>>?> build() async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    if (authOutput is AuthUser) {
      user = authOutput;
    }

    user!.client.onGuildMemberListUpdate.listen((event) {
      if (event.eventType == MemberListUpdateType.sync) {
        List<GuildMemberListGroup> groupList =
            List<GuildMemberListGroup>.from(event.groups);

        updateMemberList(event.memberList!, groupList);
      }
    });

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

  void unloadMemberRange(int lowerBound, int upperBound) {
    currentSubscriptions.removeWhere((sub) =>
        sub.memberRange.lowerMemberBound == lowerBound &&
        sub.memberRange.upperMemberBound == upperBound);
    _updateSubscriptions();

    // Remove the unloaded members from the local state
    if (lastPair != null) {
      var updatedMemberList = lastPair!.second.where((member) {
        if (member is Member) {
          int index = lastPair!.second.indexOf(member);
          return index < lowerBound || index > upperBound;
        }
        return true;
      }).toList();

      state = AsyncValue.data(Pair(lastPair!.first, updatedMemberList));
    }
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
      List<dynamic> memberList, List<GuildMemberListGroup> groups) {
    lastPair = Pair(groups, memberList);
    state = AsyncValue.data(lastPair!);
  }
}
