import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/channel_members.dart';
import 'package:bonfire/features/member/components/group.dart';
import 'package:bonfire/features/member/components/member_card.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:firebridge/firebridge.dart';
import 'package:go_router/go_router.dart';
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
        border: Border(
          left: BorderSide(
            color: Theme.of(context).custom.colorTheme.foreground,
            width: 1,
          ),
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
  bool _isLoadingMore = false; // to prevent multiple simultaneous triggers
  late final GoRouter _router;

  void _onRouteChanged() {
    Snowflake newGuildId = Snowflake.parse(
      _router.routerDelegate.currentConfiguration.pathParameters["guildId"] ??
          '0',
    );
    String? cId =
        _router.routerDelegate.currentConfiguration.pathParameters["channelId"];
    if (cId == null) return;
    Snowflake newChannelId = Snowflake.parse(cId);
    ref
        .read(channelMembersProvider.notifier)
        .setRoute(newGuildId, newChannelId);
  }

  @override
  void initState() {
    super.initState();
    _router = GoRouter.of(context);
    _router.routerDelegate.addListener(_onRouteChanged);
    _scrollController.addListener(_onScroll);
    ref
        .read(channelMembersProvider.notifier)
        .setRoute(widget.guild.id, widget.channel.id);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onScroll() {
    // When within 300 pixels of the bottom, load the next range.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (!_isLoadingMore) {
        _isLoadingMore = true;
        _loadMoreData();
      }
    }
  }

  void _loadMoreData() {
    final channelMembersNotifier = ref.read(channelMembersProvider.notifier);

    int nextLowerBound = 0;
    if (channelMembersNotifier.currentSubscriptions.isNotEmpty) {
      final maxUpperBound = channelMembersNotifier.currentSubscriptions
          .expand((sub) => sub.memberRange)
          .map((range) => range.upperMemberBound)
          .reduce((a, b) => a > b ? a : b);
      nextLowerBound = maxUpperBound + 1;
    }

    int nextUpperBound = nextLowerBound + 99;

    print("Loading next range: $nextLowerBound - $nextUpperBound");
    channelMembersNotifier.loadMemberRange(nextLowerBound, nextUpperBound);

    Future.delayed(const Duration(milliseconds: 500), () {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var memberListPair =
        ref.watch(guildMemberListProvider(widget.guild.id)).valueOrNull;
    var groupList = memberListPair?.first ?? [];
    var memberList = memberListPair?.second ?? [];

    print("Length of member list: ${memberList.length}");

    return Container(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: memberList.length,
          itemBuilder: (context, index) {
            // TODO: These should absolutely not be lists of one item
            final item = memberList[index].first;

            // Handle group headers
            if (item is GuildMemberListGroup) {
              return Padding(
                padding: EdgeInsets.only(
                  left: isSmartwatch(context) ? 34 : 2,
                  top: 10,
                  bottom: 4,
                ),
                child: GroupHeader(
                  guild: widget.guild,
                  groups: groupList,
                  group: item,
                ),
              );
            }

            if (item is Member) {
              bool shouldRoundBottom = index == memberList.length - 1 ||
                  memberList[index + 1] is! Member;

              return Padding(
                padding: EdgeInsets.only(
                    right: 8, bottom: shouldRoundBottom ? 8 : 0),
                child: MemberCard(
                  member: item,
                  guild: widget.guild,
                  channel: widget.channel,
                  roundTop: index == 0 || memberList[index - 1] is! Member,
                  roundBottom: shouldRoundBottom,
                ),
              );
            }

            // Handle lists of members (from SYNC operations)
            if (item is List<Member>) {
              return Column(
                children: item.map<Widget>((member) {
                  bool shouldRoundBottom = member == item.last ||
                      (index < memberList.length - 1 &&
                          memberList[index + 1] is! List<Member>);

                  return Padding(
                    padding: EdgeInsets.only(
                      right: 8,
                      bottom: shouldRoundBottom ? 8 : 0,
                    ),
                    child: MemberCard(
                      member: member,
                      guild: widget.guild,
                      channel: widget.channel,
                      roundTop: member == item.first &&
                          (index == 0 ||
                              memberList[index - 1] is! List<Member>),
                      roundBottom: shouldRoundBottom,
                    ),
                  );
                }).toList(),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}
