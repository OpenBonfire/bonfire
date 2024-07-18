import 'package:bonfire/features/channels/views/channels.dart';
import 'package:bonfire/features/members/views/member_list.dart';
import 'package:bonfire/features/messaging/views/messages.dart';
import 'package:bonfire/features/overview/controllers/navigation_bar.dart';
import 'package:bonfire/features/overview/views/navigator.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/features/sidebar/views/sidebar.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeMobile extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  const HomeMobile({super.key, required this.guildId, required this.channelId});

  @override
  ConsumerState<HomeMobile> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeMobile> {
  RevealSide selfPanelState = RevealSide.main;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // TODO: Make this less hacky
      /*
        This works because there's a bug on initstate for the panels.
        When the panels are initialized *at all*, they will return to the
        `right` state. I think this may break once that is fixed.

        Currently, we don't even need `selfPanelState`, we could actually
        just guess the `right` state and be correct.
      */
      ref.read(navigationBarProvider.notifier).onSideChange(selfPanelState);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            OverlappingPanels(
              onSideChange: (value) {
                FocusScope.of(context).unfocus();
                selfPanelState = value;
                ref.read(navigationBarProvider.notifier).onSideChange(value);
              },
              left: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Sidebar(
                      guildId: widget.guildId,
                    ),
                    Expanded(
                        child: Expanded(
                            child: ChannelsList(
                      guildId: widget.guildId,
                      channelId: widget.channelId,
                    )))
                  ],
                ),
              ),
              main: MessageView(
                guildId: widget.guildId,
                channelId: widget.channelId,
              ),
              right: MemberList(
                guildId: widget.guildId,
                channelId: widget.channelId,
              ),
            ),
            const NavigationBarWidget()
          ],
        ));
  }
}
