import 'package:bonfire/features/channels/components/channel_sidebar.dart';
import 'package:bonfire/features/members/components/member_list.dart';
import 'package:bonfire/shared/components/divider.dart';
import 'package:bonfire/shared/components/navigation/adaptive_panel_layout.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelRouterWrapper extends ConsumerWidget {
  final Snowflake? guildId;
  final Snowflake? channelId;
  final Widget child;
  const ChannelRouterWrapper({
    super.key,
    this.guildId,
    this.channelId,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AdaptivePanelLayout(
        left: Row(
          children: [
            ChannelSidebar(guildId: guildId, channelId: channelId),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: BonfireVerticalDivider(),
            ),
          ],
        ),
        main: child,
        right: (guildId != null && channelId != null)
            ? SizedBox(
                width: 275,
                child: MemberList(guildId: guildId!, channelId: channelId!),
              )
            : null,
      ),
    );
  }
}
