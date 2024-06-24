import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/current_guild.dart';
import 'package:bonfire/shared/models/pair.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'channel_members.g.dart';

@riverpod
class ChannelMembers extends _$ChannelMembers {
  AuthUser? user;

  @override
  Future<Pair<List<GuildMemberListGroup>, List<dynamic>>?> build() async {
    final currentChannel = ref.watch(channelControllerProvider);
    final currentGuild = ref.watch(currentGuildControllerProvider);

    var authOutput = ref.watch(authProvider.notifier).getAuth();
    if (authOutput is AuthUser &&
        currentChannel != null &&
        currentGuild != null) {
      authOutput.client
          .updateGuildSubscriptionsBulk(GuildSubscriptionsBulkBuilder()
            ..subscriptions = [
              GuildSubscription(
                  typing: true,
                  memberUpdates: true,
                  channels: [
                    GuildSubscriptionChannel(
                      channelId: currentChannel.id,
                      memberRange: GuildMemberRange(
                        lowerMemberBound: 0,
                        upperMemberBound: 99,
                      ),
                    )
                  ],
                  guildId: currentGuild.id)
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