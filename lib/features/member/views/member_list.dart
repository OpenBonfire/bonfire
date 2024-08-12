import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/channel_members.dart';
import 'package:bonfire/features/member/views/components/group.dart';
import 'package:bonfire/features/member/views/components/member_card.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:firebridge/firebridge.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
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
                left: (shouldUseMobileLayout(context) && !isSmartwatch(context))
                    ? 32
                    : 8,
              ),
              child: MemberScrollView(
                guild: guild,
                channel: channel,
              ),
            ),
          )
        ],
      ),
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
  final ScrollController _scrollController = ScrollController();
  List<int> loadedChunks = [0]; // Always keep 0-99 loaded

  @override
  void initState() {
    super.initState();
    ref
        .read(channelMembersProvider.notifier)
        .setRoute(widget.guild.id, widget.channel.id);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // if (_scrollController.position.pixels ==
    //     _scrollController.position.maxScrollExtent) {
    //   _loadMoreData();
    // }
  }

  bool isMember(dynamic item) {
    return item[0] is Member;
  }

  @override
  Widget build(BuildContext context) {
    var memberListPair = ref.watch(channelMembersProvider).valueOrNull;

    var groupList = memberListPair?.first ?? [];
    var memberList = memberListPair?.second ?? [];

    return ListView.builder(
      controller: _scrollController,
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
                    right: 8, bottom: shouldRoundBottom ? 8 : 0),
                child: MemberCard(
                  member: member,
                  guild: widget.guild,
                  channel: widget.channel,
                  roundTop: (index == 0) || (!isMember(memberList[index - 1])),
                  roundBottom: shouldRoundBottom,
                ),
              );
            }).toList(),
          );
        }
        // return Text((memberList[index] as List<dynamic>).length.toString());
        if ((memberList[index] as List<dynamic>).isEmpty) {
          return Container();
        }
        var headerGroup = memberList[index][0] as GuildMemberListGroup;

        return Padding(
          padding: EdgeInsets.only(
              left: isSmartwatch(context) ? 34 : 2, top: 10, bottom: 4),
          child: GroupHeader(
            guild: widget.guild,
            groups: groupList,
            group: headerGroup,
          ),
        );
      },
    );
  }
}
