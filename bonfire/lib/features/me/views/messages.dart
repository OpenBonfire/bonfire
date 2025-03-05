import 'package:bonfire/features/friends/views/friends.dart';
import 'package:bonfire/features/me/components/private_messages.dart';
import 'package:bonfire/features/member/views/member_list.dart';
import 'package:bonfire/features/me/components/messages.dart';
import 'package:bonfire/features/overview/controllers/navigation_bar.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/features/sidebar/views/sidebar.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:firebridge/firebridge.dart' hide Builder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageOverview extends ConsumerStatefulWidget {
  final Snowflake? channelId;
  const MessageOverview({super.key, this.channelId});

  @override
  ConsumerState<MessageOverview> createState() => _MessageOverviewState();
}

class _MessageOverviewState extends ConsumerState<MessageOverview> {
  RevealSide selfPanelState = RevealSide.main;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (shouldUseDesktopLayout(context)) {
            return Row(
              children: [
                Sidebar(guildId: Snowflake.zero),
                SizedBox(
                  width: 275,
                  child: PrivateMessages(
                    channelId: widget.channelId ?? Snowflake.zero,
                  ),
                ),
                (widget.channelId != null)
                    ? Expanded(
                        child: MessageView(
                          guildId: Snowflake.zero,
                          channelId: widget.channelId!,
                        ),
                      )
                    : Expanded(
                        child: FriendsList(
                          channelId: Snowflake.zero,
                        ),
                      ),
              ],
            );
          } else {
            return OverlappingPanels(
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
                      guildId: Snowflake.zero,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: PrivateMessages(
                          channelId: widget.channelId ?? Snowflake.zero,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              main: (widget.channelId != null)
                  ? MessageView(
                      guildId: Snowflake.zero,
                      channelId: widget.channelId!,
                    )
                  : FriendsList(
                      channelId: Snowflake.zero,
                    ),
              right: (widget.channelId != null)
                  ? MemberList(
                      guildId: Snowflake.zero,
                      channelId: widget.channelId!,
                    )
                  : const SizedBox(),
            );
          }
        },
      ),
    );
  }
}
