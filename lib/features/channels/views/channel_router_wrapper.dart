import 'package:bonfire/features/channels/components/channel_sidebar.dart';
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
        left: ChannelSidebar(guildId: guildId, channelId: channelId),
        main: child,
      ),
    );
  }
}
