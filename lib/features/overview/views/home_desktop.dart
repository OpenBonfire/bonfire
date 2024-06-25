import 'package:bonfire/features/channels/views/channels.dart';
import 'package:bonfire/features/members/views/member_list.dart';
import 'package:bonfire/features/messaging/views/messages.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/features/overview/views/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeDesktop extends ConsumerStatefulWidget {
  const HomeDesktop({super.key});

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
    return const Scaffold(
        resizeToAvoidBottomInset: false,
        body: Row(
          children: [
            Sidebar(),
            SizedBox(width: 300, child: ChannelsList()),
            Flexible(child: MessageView()),
            SizedBox(
              width: 300,
              child: MemberList(),
            )
          ],
        ));
  }
}
