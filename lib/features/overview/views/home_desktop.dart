import 'package:bonfire/features/channels/views/channels.dart';
import 'package:bonfire/features/members/views/member_list.dart';
import 'package:bonfire/features/messaging/views/messages.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/features/overview/views/sidebar.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeDesktop extends ConsumerStatefulWidget {
  final Guild guild;
  final Channel channel;
  const HomeDesktop({super.key, required this.guild, required this.channel});

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
              key: const Key('sidebar'),
              guild: widget.guild,
            ),
            SizedBox(
              key: const Key('channels'),
              width: 300,
              child: ChannelsList(
                guild: widget.guild,
                channel: widget.channel,
              ),
            ),
            Flexible(
              child: MessageView(
                guild: widget.guild,
                channel: widget.channel,
              ),
            ),
            SizedBox(
              width: 300,
              child: MemberList(
                guild: widget.guild,
                channel: widget.channel,
              ),
            )
          ],
        ));
  }
}
