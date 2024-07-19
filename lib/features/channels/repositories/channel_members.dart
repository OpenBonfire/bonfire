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

  @override
  Future<Pair<List<GuildMemberListGroup>, List<dynamic>>?> build() async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    if (authOutput is AuthUser) {
      user = authOutput;
    }

    user!.client.onGuildMemberListUpdate.listen((event) {
      if (event.eventType == MemberListUpdateType.sync) {
        // for some reason I can't directly cast
        List<GuildMemberListGroup> groupList =
            List<GuildMemberListGroup>.from(event.groups);

        updateMemberList(event.memberList!, groupList);
      }
    });

    return null;
  }

  void setRoute(Snowflake guildId, Snowflake channelId) async {
    if (user is AuthUser) {
      user!.client.updateGuildSubscriptionsBulk(GuildSubscriptionsBulkBuilder()
        ..subscriptions = [
          GuildSubscription(
              typing: true,
              memberUpdates: true,
              channels: [
                GuildSubscriptionChannel(
                  channelId: channelId,
                  memberRange: GuildMemberRange(
                    lowerMemberBound: 0,
                    upperMemberBound: 99,
                  ),
                )
              ],
              guildId: guildId)
        ]);
    }
  }

  void updateMemberList(
      List<dynamic> memberList, List<GuildMemberListGroup> groups) {
    state = AsyncValue.data(Pair(groups, memberList));
  }
}
