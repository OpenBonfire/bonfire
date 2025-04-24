import 'package:bonfire/features/channels/views/channels.dart';
import 'package:bonfire/features/friends/views/friends.dart';
import 'package:bonfire/features/me/components/private_messages.dart';
import 'package:bonfire/features/member/views/member_list.dart';
import 'package:bonfire/features/me/components/messages.dart';
import 'package:bonfire/features/overview/controllers/channel_list_width.dart';
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

  static const double minChannelListWidth = 180.0;
  static const double maxChannelListWidth = 400.0;
  static const double sidebarWidth = 65.0;

  @override
  void initState() {
    print("init home desktop");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isVisible = ref.watch(memberListVisibilityProvider);
    int channelListWidth = ref.watch(channelListWidthProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Row(
            children: [
              Sidebar(
                guildId: widget.guildId,
              ),
              SizedBox(
                width: channelListWidth.toDouble(),
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
          ),
          Positioned(
            left: sidebarWidth + channelListWidth,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final newWidth = (localPosition.dx - sidebarWidth).toInt();

                if (newWidth >= minChannelListWidth &&
                    newWidth <= maxChannelListWidth) {
                  ref.read(channelListWidthProvider.notifier).setSize(newWidth);
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: Container(
                  width: 4,
                  // color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
