import 'package:bonfire/features/channels/views/channels.dart';
import 'package:bonfire/features/friends/views/friends.dart';
import 'package:bonfire/features/me/components/private_messages.dart';
import 'package:bonfire/features/member/views/member_list.dart';
import 'package:bonfire/features/me/components/messages.dart';
import 'package:bonfire/features/overview/controllers/member_list.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/features/sidebar/views/sidebar.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeDesktop extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  final Snowflake? threadId;
  const HomeDesktop({
    super.key,
    required this.guildId,
    required this.channelId,
    this.threadId,
  });

  @override
  ConsumerState<HomeDesktop> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeDesktop> {
  RevealSide selfPanelState = RevealSide.main;

  @override
  void initState() {
    print("init home desktop");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isVisible = ref.watch(memberListVisibilityProvider);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Row(
          children: [
            Sidebar(
              guildId: widget.guildId,
            ),
            SizedBox(
              width: 255,
              child: (widget.guildId != Snowflake.zero)
                  ? ChannelsList(
                      guildId: widget.guildId,
                      channelId: widget.channelId,
                    )
                  : PrivateMessages(channelId: widget.channelId),
            ),
            Flexible(
              child: (widget.channelId != Snowflake.zero)
                  ? MessageView(
                      guildId: widget.guildId,
                      channelId: widget.channelId,
                      threadId: widget.threadId,
                    )
                  : FriendsList(channelId: Snowflake.zero),
            ),
            if (isVisible)
              SizedBox(
                width: 255,
                child: (widget.channelId != Snowflake.zero)
                    ? MemberList(
                        guildId: widget.guildId, channelId: widget.channelId)
                    : const SizedBox(),
              )
          ],
        ));
  }
}
