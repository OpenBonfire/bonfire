import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/shared/models/pair.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'channel_members.g.dart';

@Riverpod(keepAlive: true)
class ChannelMembers extends _$ChannelMembers {
  AuthUser? user;

  @override
  Future<Pair<List<GuildMemberListGroup>, List<dynamic>>?> build(
      Snowflake guildId, Snowflake channelId) async {
    final guild = await ref.watch(guildControllerProvider(guildId).future);
    final channel =
        await ref.watch(channelControllerProvider(channelId).future);

    var authOutput = ref.watch(authProvider.notifier).getAuth();
    if (authOutput is AuthUser && channel != null && guild != null) {
      authOutput.client
          .updateGuildSubscriptionsBulk(GuildSubscriptionsBulkBuilder()
            ..subscriptions = [
              GuildSubscription(
                  typing: true,
                  memberUpdates: true,
                  channels: [
                    GuildSubscriptionChannel(
                      channelId: channel.id,
                      memberRange: GuildMemberRange(
                        lowerMemberBound: 0,
                        upperMemberBound: 99,
                      ),
                    )
                  ],
                  guildId: guild.id)
            ]);

      authOutput.client.onGuildMemberListUpdate.listen((event) {
        if (event.eventType == MemberListUpdateType.sync) {
          // for some reason I can't directly cast
          List<GuildMemberListGroup> groupList =
              List<GuildMemberListGroup>.from(event.groups);

          updateMemberList(event.memberList!, groupList);
        }
      });
    }

    return null;
  }

  void updateMemberList(
      List<dynamic> memberList, List<GuildMemberListGroup> groups) {
    state = AsyncValue.data(Pair(groups, memberList));
  }
}
