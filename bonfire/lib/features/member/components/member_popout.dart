import 'dart:math';

import 'package:bonfire/features/friends/views/friend_card.dart';
import 'package:bonfire/features/guild/controllers/role.dart';
import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/member/repositories/user_profile.dart';
import 'package:bonfire/features/user/components/presence_avatar.dart';
import 'package:bonfire/features/user/controllers/presence.dart';
import 'package:bonfire/shared/components/drawer/mobile_drawer.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:bonfire/shared/utils/style/markdown/stylesheet.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:collection/collection.dart';
import 'package:firebridge/firebridge.dart' hide Builder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_prism/flutter_prism.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPopoutCard extends ConsumerStatefulWidget {
  final Snowflake userId;
  final Snowflake guildId;
  const UserPopoutCard(this.userId, {super.key, required this.guildId});

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorTheme.foreground,
        ),
        width: 500,
        height: 650,
        child: (profile != null)
            ? Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (banner != null)
                        Image.network(
                          "${banner.url}?size=480",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                        )
                      else
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: (profile.userProfile.accentColor != null)
                                ? Color(profile.userProfile.accentColor!)
                                    .withAlpha(255)
                                : theme.colorTheme.background,
                          ),
                        ),
                      const SizedBox(height: 50),
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
                                  .titleMedium,
                            ),
                            Text(
                              profile.user.username,
                              style: Theme.of(context).custom.textTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: UserInfoTabView(
                        profile,
                        guildId: widget.guildId,
                      )),
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
                  ),
                ],
              )
            : Container(),
      ),
    );
  }
}

class UserInfoTabView extends ConsumerStatefulWidget {
  final UserProfile userProfile;
  final Snowflake guildId;
  const UserInfoTabView(this.userProfile, {super.key, required this.guildId});

  @override
  ConsumerState<UserInfoTabView> createState() => _UserInfoTabViewState();
}

class _UserInfoTabViewState extends ConsumerState<UserInfoTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Function()? _drawerListener;
  double drawerHeight = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shouldUseMobileLayout(context)) {
        GlobalDrawer.of(context)!.controller.addListener(_drawerListener);
      }
    });
  }

  void _drawerListener() {
    final drawer = GlobalDrawer.of(context);
    if (drawer == null) return;
    setState(() {
      drawerHeight = GlobalDrawer.of(context)!.controller.value;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    GlobalDrawer.of(context)?.controller.removeListener(_drawerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TabBar(
                controller: _tabController,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Theme.of(context).custom.colorTheme.blurple,
                labelColor: Colors.white,
                onTap: (index) {
                  HapticFeedback.lightImpact();
                },
                tabs: const [
                  Tab(text: "About"),
                  Tab(text: "Mutual Friends"),
                  Tab(text: "Mutual Servers"),
                ],
              ),
            ),
          ),
          // I really hate this method of laying out, but it's all I can come up with
          // it won't lay out when using any other method, like expanded, flex, etc.

          SizedBox(
            height: shouldUseDesktopLayout(context)
                ? 332
                : max(
                    drawerHeight * MediaQuery.of(context).size.height - 318, 0),
            child: TabBarView(
              controller: _tabController,
              children: [
                AboutUserTab(
                  widget.userProfile,
                  guildId: widget.guildId,
                ),
                MutualFriends(widget.userProfile),
                const Center(
                    child: Text(
                        "I'll add the guild card soon I just gotta make the buttons and stuff")),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AboutUserTab extends ConsumerStatefulWidget {
  final UserProfile userProfile;
  final Snowflake guildId;
  const AboutUserTab(this.userProfile, {super.key, required this.guildId});

  @override
  ConsumerState<AboutUserTab> createState() => _AboutUserTabState();
}

class _AboutUserTabState extends ConsumerState<AboutUserTab> {
  Widget bioCard(String bio) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About Me",
            style: Theme.of(context).custom.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownViewer(
                bio,
                enableTaskList: true,
                enableSuperscript: false,
                enableSubscript: false,
                enableFootnote: false,
                enableImageSize: false,
                selectable: shouldUseDesktopLayout(context),
                enableKbd: false,
                syntaxExtensions: const [],
                elementBuilders: const [],
                highlightBuilder: (text, language, infoString) {
                  final prism = Prism(
                    style: Theme.of(context).brightness == Brightness.dark
                        ? const PrismStyle.dark()
                        : const PrismStyle(),
                  );
                  try {
                    var rendered = prism.render(text, language ?? 'plain');
                    return rendered;
                  } catch (e) {
                    return <TextSpan>[TextSpan(text: text)];
                  }
                },
                onTapLink: (href, title) {
                  if (href != null) {
                    launchUrl(Uri.parse(href),
                        mode: LaunchMode.externalApplication);
                  }
                },
                styleSheet: getMarkdownStyleSheet(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget rolesCard() {
    final member = ref
        .watch(getMemberProvider(widget.guildId, widget.userProfile.user.id))
        .valueOrNull;

    if (member == null) {
      return LoadingAnimationWidget.fallingDot(
          color: Theme.of(context).custom.colorTheme.deselectedChannelText,
          size: 24);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Roles",
              style: Theme.of(context).custom.textTheme.titleSmall,
            ),
            Wrap(
              spacing: 6,
              // I cannot explain this, and I am very sorry it was ever written
              runSpacing: -12,
              children: [
                for (var roleId in member.roleIds)
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Builder(builder: (context) {
                      // print("looking for role ${roleId}");
                      var role = ref.watch(roleControllerProvider(roleId))!;
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
                            foregroundColor: Theme.of(context)
                                .custom
                                .colorTheme
                                .selectedChannelText,
                            backgroundColor:
                                Theme.of(context).custom.colorTheme.foreground,
                          ),
                          onPressed: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, role.color.r,
                                        role.color.g, role.color.b),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(role.name,
                                    style: Theme.of(context)
                                        .custom
                                        .textTheme
                                        .caption
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                        )),
                              ],
                            ),
                          ));
                    }),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bio = widget.userProfile.userProfile.bio;
    return ListView(
      padding: EdgeInsets.only(
        top: 8.0,
        left: 8.0,
        right: 8.0,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      children: [
        if (bio != "")
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: bioCard(bio ?? ""),
          ),
        rolesCard(),
      ],
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
      padding: EdgeInsets.only(
          top: 8.0, bottom: MediaQuery.of(context).padding.bottom),
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
