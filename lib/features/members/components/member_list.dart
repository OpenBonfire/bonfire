import 'package:bonfire/features/gateway/store/entity_store.dart';
import 'package:bonfire/features/members/repositories/channel_members.dart';
import 'package:bonfire/features/members/components/group.dart';
import 'package:bonfire/features/members/components/member_card.dart';
import 'package:bonfire/shared/utils/channel_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(0)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 20),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Text(
                "# $channelName",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                channelDescription,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Channel? channel = ref.watch(channelProvider(widget.channelId));
    Guild? guild = ref.watch(guildProvider(widget.guildId));

    if (channel == null || guild == null) {
      return const Center(child: CircularProgressIndicator());
    }

    String channelName = getChannelName(channel);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(color: theme.colorScheme.surfaceContainer, width: 1),
        ),
      ),
      child: Column(
        children: [
          if (!isSmartwatch(context))
            Padding(
              padding: EdgeInsets.only(
                left: UniversalPlatform.isDesktop ? 8.0 : 0,
              ),
              child: topBox(channelName, ""),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: (shouldUseMobileLayout(context) && !isSmartwatch(context))
                    ? 32
                    : 8,
              ),
              child: MemberScrollView(guild: guild, channel: channel),
            ),
          ),
        ],
      ),
    );
  }
}

class MemberScrollView extends ConsumerStatefulWidget {
  final Guild guild;
  final Channel channel;
  const MemberScrollView({
    super.key,
    required this.guild,
    required this.channel,
  });

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
    // OverlappingPanelsState? panels = OverlappingPanels.of(context);

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
        _scrollController.position.maxScrollExtent - 1000) {
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
      final maxUpperBound = channelMembersNotifier.currentSubscriptions.values
          .expand((ranges) => ranges)
          .map((range) => range[1])
          .reduce((a, b) => a > b ? a : b);
      nextLowerBound = maxUpperBound + 1;
    }

    int nextUpperBound = nextLowerBound + 99;

    debugPrint("Loading next range: $nextLowerBound - $nextUpperBound");
    channelMembersNotifier.loadMemberRange(nextLowerBound, nextUpperBound);

    Future.delayed(const Duration(milliseconds: 500), () {
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memberListPair = ref
        .watch(guildMemberListProvider(widget.guild.id))
        .value;
    final groupList = memberListPair?.first ?? [];
    final memberList = memberListPair?.second ?? [];

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: memberList.length,
          itemBuilder: (context, index) {
            final itemWrapper = memberList[index];

            if (itemWrapper is GuildMemberListUpdateItem) {
              if (itemWrapper.group != null) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: isSmartwatch(context) ? 34 : 2,
                    top: 10,
                    bottom: 4,
                  ),
                  child: GroupHeader(
                    guild: widget.guild,
                    groups: groupList,
                    group: itemWrapper.group!,
                  ),
                );
              }

              if (itemWrapper.member != null) {
                bool shouldRoundBottom =
                    index == memberList.length - 1 ||
                    (memberList[index + 1] is GuildMemberListUpdateItem &&
                        (memberList[index + 1] as GuildMemberListUpdateItem)
                                .group !=
                            null);

                bool shouldRoundTop =
                    index == 0 ||
                    (memberList[index - 1] is GuildMemberListUpdateItem &&
                        (memberList[index - 1] as GuildMemberListUpdateItem)
                                .group !=
                            null);

                return Padding(
                  padding: EdgeInsets.only(
                    right: 8,
                    bottom: shouldRoundBottom ? 8 : 0,
                  ),
                  child: MemberCard(
                    member: itemWrapper.member!,
                    guild: widget.guild,
                    channel: widget.channel,
                    roundTop: shouldRoundTop,
                    roundBottom: shouldRoundBottom,
                  ),
                );
              }
            }

            return Container();
          },
        ),
      ),
    );
  }
}
