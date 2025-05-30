import 'package:bonfire/features/friends/views/friends.dart';
import 'package:bonfire/features/me/components/private_messages.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/features/channels/views/channels.dart';
import 'package:bonfire/features/member/views/member_list.dart';
import 'package:bonfire/features/me/components/messages.dart';
import 'package:bonfire/features/overview/controllers/navigation_bar.dart';
import 'package:bonfire/features/overview/views/navigator.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/features/sidebar/views/sidebar.dart';
import 'package:firebridge/firebridge.dart';
import 'package:bonfire/shared/utils/platform.dart';

class HomeMobile extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  final Snowflake? threadId;
  const HomeMobile({
    super.key,
    required this.guildId,
    required this.channelId,
    this.threadId,
  });

  @override
  ConsumerState<HomeMobile> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeMobile>
    with SingleTickerProviderStateMixin {
  RevealSide currentPanel = RevealSide.main;
  final GlobalKey<OverlappingPanelsState> _panelsKey =
      GlobalKey<OverlappingPanelsState>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool showMemberList = false;
  bool showChannelList = false;
  // double panelPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 0).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      OverlappingPanelsState? panelsState = _panelsKey.currentState;
      panelsState!.position.addListener(() {
        final panelPosition = panelsState.position.value;
        if (panelPosition < 0) {
          if (showMemberList == false) {
            setState(() {
              showMemberList = true;
            });
          }
        } else {
          if (showMemberList == true) {
            setState(() {
              showMemberList = false;
            });
          }
        }

        if (panelPosition <= 0) {
          if (showChannelList == true) {
            setState(() {
              showChannelList = false;
            });
          }
        } else {
          if (showChannelList == false) {
            setState(() {
              showChannelList = true;
            });
          }
        }
      });

      ref.read(navigationBarProvider.notifier).onSideChange(currentPanel);
      if (widget.channelId == Snowflake.zero) {
        panelsState.moveToState(RevealSide.left);
        ref.read(navigationBarProvider.notifier).onSideChange(RevealSide.left);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _cyclePanel() {
    OverlappingPanelsState? panelsState = _panelsKey.currentState;
    if (panelsState == null) return;

    setState(() {
      switch (currentPanel) {
        case RevealSide.right:
          currentPanel = RevealSide.main;
          panelsState.moveToState(RevealSide.main);
          break;
        case RevealSide.main:
          currentPanel = RevealSide.left;
          panelsState.moveToState(RevealSide.left);
          _animationController.forward();
          break;
        case RevealSide.left:
          // no point in showing here
          break;
      }
    });
    ref.read(navigationBarProvider.notifier).onSideChange(currentPanel);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OverlappingPanels(
          key: _panelsKey,
          onSideChange: (value) {
            FocusScope.of(context).unfocus();
            setState(() {
              currentPanel = value;
              if (value != RevealSide.left) {
                _animationController.reverse();
              }
            });
            ref.read(navigationBarProvider.notifier).onSideChange(value);
          },
          left: (showChannelList)
              ? SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: Row(
                    children: [
                      Sidebar(guildId: widget.guildId),
                      Expanded(
                        child: (widget.guildId != Snowflake.zero)
                            ? ChannelsList(
                                guildId: widget.guildId,
                                channelId: widget.channelId,
                              )
                            : PrivateMessages(
                                channelId: widget.channelId,
                              ),
                      )
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          main: (widget.channelId != Snowflake.zero)
              ? MessageView(
                  guildId: widget.guildId,
                  channelId: widget.channelId,
                  threadId: widget.threadId,
                )
              : FriendsList(
                  channelId: Snowflake.zero,
                ),
          right: (widget.channelId != Snowflake.zero && (showMemberList))
              ? MemberList(
                  guildId: widget.guildId,
                  channelId: widget.channelId,
                )
              : const SizedBox(),
          restWidth: isSmartwatch(context) ? 0.0 : 0.0,
        ),
        if (!isSmartwatch(context)) const NavigationBarWidget(),
        if (isSmartwatch(context))
          Positioned(
            top: 15,
            left: 15,
            child: FadeTransition(
              opacity: _animation,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.black.withOpacity(0.5),
                onPressed: _cyclePanel,
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
