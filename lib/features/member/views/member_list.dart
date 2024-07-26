import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/channel_members.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/member/views/components/group.dart';
import 'package:bonfire/features/member/views/components/member_card.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:universal_platform/universal_platform.dart';

class MemberList extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  const MemberList({super.key, required this.guildId, required this.channelId});

  @override
  ConsumerState<MemberList> createState() => _MemberListState();
}

class _MemberListState extends ConsumerState<MemberList> {
  Widget topBox(String channelName, String channelDescription) {
    return Container(
      width: double.infinity,
      // height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
        child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Text(
                  "# $channelName",
                  style: Theme.of(context).custom.textTheme.titleSmall,
                ),
                Text(
                  channelDescription,
                  style: Theme.of(context).custom.textTheme.subtitle2,
                ),
              ],
            )),
      ),
    );
  }

  String getChannelName(Channel channel) {
    return (channel as GuildChannel).name;

    // if (channel.type == ChannelType) {
    //   return (channel as GuildChannel).name;
    // } else {
    //   return "Name not implemented.";
    // }
  }

  @override
  Widget build(BuildContext context) {
    Channel? channel =
        ref.watch(channelControllerProvider(widget.channelId)).valueOrNull;
    Guild? guild =
        ref.watch(guildControllerProvider(widget.guildId)).valueOrNull;

    if (channel == null || guild == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    String channelName = getChannelName(channel);

    return Column(
      children: [
        if (!isSmartwatch(context))
          Padding(
            padding:
                EdgeInsets.only(left: UniversalPlatform.isDesktop ? 8.0 : 0),
            child: topBox(channelName, ""),
          ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(
            left:
                (UniversalPlatform.isMobile && !isSmartwatch(context)) ? 32 : 0,
          ),
          child: MemberScrollView(
            guild: guild,
            channel: channel,
          ),
        ))
      ],
    );
  }
}

class MemberScrollView extends ConsumerStatefulWidget {
  final Guild guild;
  final Channel channel;
  const MemberScrollView(
      {super.key, required this.guild, required this.channel});

  @override
  ConsumerState<MemberScrollView> createState() => MemberScrollViewState();
}

class MemberScrollViewState extends ConsumerState<MemberScrollView> {
  @override
  void initState() {
    super.initState();
    ref
        .read(channelMembersProvider.notifier)
        .setRoute(widget.guild.id, widget.channel.id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isMember(dynamic item) {
    // I'm so sorry
    // this absolutely needs to be refactored
    // I should probably just make a new object with a 'type' parameter
    return item.toString().contains("Member(");
  }

  @override
  Widget build(BuildContext context) {
    var memberListPair = ref.watch(channelMembersProvider).valueOrNull;

    var groupList = memberListPair?.first ?? [];
    var memberList = memberListPair?.second ?? [];

    return SizedBox(
      child: ListView.builder(
        itemCount: memberList.length,
        itemBuilder: (context, index) {
          if (isMember(memberList[index])) {
            var members = memberList[index] as List;
            return Column(
              children: members.map<Widget>((member) {
                member = member as Member;
                bool shouldRoundBottom = (index == memberList.length - 1) ||
                    (!isMember(memberList[index + 1]));
                return Padding(
                  padding: EdgeInsets.only(
                      right: 12, bottom: shouldRoundBottom ? 8 : 0),
                  child: MemberCard(
                    member: member,
                    guild: widget.guild,
                    channel: widget.channel,
                    roundTop:
                        (index == 0) || (!isMember(memberList[index - 1])),
                    roundBottom: shouldRoundBottom,
                  ),
                );
              }).toList(),
            );
          }
          // print(memberList[index][0]);
          return Padding(
            padding: EdgeInsets.only(
                left: isSmartwatch(context) ? 34 : 2, top: 10, bottom: 4),
            child: GroupHeader(
              guild: widget.guild,
              groups: groupList,
              group: memberList[index][0] as GuildMemberListGroup,
            ),
          );
        },
      ),
    );
  }
}