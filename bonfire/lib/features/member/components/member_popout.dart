import 'package:bonfire/features/friends/views/friend_card.dart';
import 'package:bonfire/features/member/repositories/user_profile.dart';
import 'package:bonfire/features/user/components/presence_avatar.dart';
import 'package:bonfire/features/user/controllers/presence.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:collection/collection.dart';
import 'package:firebridge/firebridge.dart' hide Builder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPopoutCard extends ConsumerStatefulWidget {
  final Snowflake userId;
  const UserPopoutCard(this.userId, {super.key});

  @override
  ConsumerState<UserPopoutCard> createState() => _UserPopoutCardState();
}

class _UserPopoutCardState extends ConsumerState<UserPopoutCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).custom;
    final profile =
        ref.watch(userProfileControllerProvider(widget.userId)).valueOrNull;
    final banner = profile?.user.banner;

    PresenceUpdateEvent? presence =
        ref.watch(presenceControllerProvider(widget.userId));

    final guildMemberProfile = profile?.guildMemberProfile;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
          decoration: BoxDecoration(
            color: theme.colorTheme.foreground,
          ),
          width: 500,
          height: 600,
          child: (profile != null)
              ? Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (banner != null)
                            ? Image.network(
                                "${banner.url}?size=480",
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150,
                              )
                            : Container(
                                height: 150,
                                decoration: BoxDecoration(
                                    color: (profile.userProfile.accentColor !=
                                            null)
                                        ? Color(profile
                                                .userProfile.accentColor!)
                                            .withAlpha(255)
                                        : theme.colorTheme.background),
                              ),
                        const SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  profile.guildMember?.nick ??
                                      profile.user.globalName ??
                                      profile.user.username,
                                  style: Theme.of(context)
                                      .custom
                                      .textTheme
                                      .titleMedium),
                              Text(profile.user.username,
                                  style: Theme.of(context)
                                      .custom
                                      .textTheme
                                      .caption),
                              // MutualFriendsInline(profile),
                              UserInfoTabView(
                                profile,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 100,
                      left: 20,
                      child: PresenceAvatar(
                        user: profile.user,
                        size: 100,
                        initialPresence: presence,
                      ),
                    )
                  ],
                )
              : Container()),
    );
  }
}

class UserInfoTabView extends ConsumerStatefulWidget {
  final UserProfile userProfile;
  const UserInfoTabView(this.userProfile, {super.key});

  @override
  ConsumerState<UserInfoTabView> createState() => _UserInfoTabViewState();
}

class _UserInfoTabViewState extends ConsumerState<UserInfoTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Theme.of(context).custom.colorTheme.blurple,
              labelColor: Colors.white,
              tabs: const [
                Tab(text: "About"),
                Tab(text: "Mutual Servers"),
                Tab(text: "Mutual Friends"),
                Tab(text: "Connections"),
              ],
            ),
          ),
          SizedBox(
            // gross
            height: 282,
            child: TabBarView(
              controller: _tabController,
              children: [
                const Center(child: Text("About Content")),
                const Center(child: Text("Mutual Servers Content")),
                // Center(child: Text("Mutual Friends Content")),
                MutualFriends(widget.userProfile),
                const Center(child: Text("Connections Content")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MutualFriends extends ConsumerStatefulWidget {
  final UserProfile userProfile;
  const MutualFriends(this.userProfile, {super.key});

  @override
  ConsumerState<MutualFriends> createState() => _MutualFriendsState();
}

class _MutualFriendsState extends ConsumerState<MutualFriends> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 8.0),
      children: [
        for (var mutualFriend in widget.userProfile.mutualFriends!)
          FriendCard(user: mutualFriend)
      ],
    );
  }
}

class MutualFriendsInline extends ConsumerStatefulWidget {
  final UserProfile userProfile;
  const MutualFriendsInline(this.userProfile, {super.key});

  @override
  ConsumerState<MutualFriendsInline> createState() =>
      _MutualFriendsInlineState();
}

class _MutualFriendsInlineState extends ConsumerState<MutualFriendsInline> {
  @override
  Widget build(BuildContext context) {
    final mutualCount = widget.userProfile.mutualFriendsCount;
    final mutuals = widget.userProfile.mutualFriends;

    int idx = 0;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.all(4),
        side: const BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        foregroundColor:
            Theme.of(context).custom.colorTheme.selectedChannelText,
        backgroundColor: Theme.of(context).custom.colorTheme.foreground,
      ),
      onPressed: () {},
      child: Row(
        children: [
          if (mutuals != null)
            Stack(
                children: mutuals
                    .map((e) => Padding(
                          padding: EdgeInsets.only(left: 16.0 * idx++),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .custom
                                      .colorTheme
                                      .background,
                                  width: 2,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(1),
                              child: PresenceAvatar(
                                user: e,
                                size: 20,
                              ),
                            ),
                          ),
                        ))
                    .toList()
                    .slice(0, 3)),
          if (mutualCount != null)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                "$mutualCount Mutual Friends",
                style: Theme.of(context).custom.textTheme.caption,
              ),
            )
        ],
      ),
    );
  }
}
