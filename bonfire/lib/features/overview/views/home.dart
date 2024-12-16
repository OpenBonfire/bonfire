import 'package:bonfire/features/overview/views/home_desktop.dart';
import 'package:bonfire/features/overview/views/home_mobile.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuildMessagingOverview extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  final Snowflake? threadId;
  const GuildMessagingOverview({
    super.key,
    required this.guildId,
    required this.channelId,
    this.threadId,
  });

  @override
  ConsumerState<GuildMessagingOverview> createState() => _HomeState();
}

class _HomeState extends ConsumerState<GuildMessagingOverview> {
  RevealSide? selfPanelState;

  @override
  void initState() {
    super.initState();
    selfPanelState = RevealSide.main;
  }

  @override
  Widget build(BuildContext context) {
    print("GuildMessagingOverview.build");
    return (shouldUseMobileLayout(context))
        ? HomeMobile(
            guildId: widget.guildId,
            channelId: widget.channelId,
            threadId: widget.threadId,
          )
        : HomeDesktop(
            guildId: widget.guildId,
            channelId: widget.channelId,
            threadId: widget.threadId,
          );
  }
}
