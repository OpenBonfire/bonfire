import 'package:bonfire/features/channels/views/channels.dart';
import 'package:bonfire/features/members/views/member_list.dart';
import 'package:bonfire/features/messaging/views/messages.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/features/sidebar/views/sidebar.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeDesktop extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  const HomeDesktop(
      {super.key, required this.guildId, required this.channelId});

  @override
  ConsumerState<HomeDesktop> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeDesktop> {
  RevealSide selfPanelState = RevealSide.main;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Row(
          children: [
            Sidebar(
              guildId: widget.guildId,
            ),
            SizedBox(
              width: 300,
              child: ChannelsList(
                guildId: widget.guildId,
                channelId: widget.channelId,
              ),
            ),
            Flexible(
              child: MessageView(
                guildId: widget.guildId,
                channelId: widget.channelId,
              ),
            ),
            SizedBox(
              width: 300,
              child: MemberList(
                guildId: widget.guildId,
                channelId: widget.channelId,
              ),
            )
          ],
        ));
  }
}
