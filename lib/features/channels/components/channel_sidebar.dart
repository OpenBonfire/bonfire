import 'package:bonfire/features/channels/components/list.dart';
import 'package:bonfire/features/guilds/components/sidebar/sidebar.dart';
import 'package:bonfire/shared/components/divider.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelSidebar extends ConsumerWidget {
  final Snowflake? guildId;
  final Snowflake? channelId;

  const ChannelSidebar({super.key, this.guildId, this.channelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 60, child: GuildSidebar()),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: BonfireVerticalDivider(),
        ),
        if (guildId != null)
          SizedBox(width: 275, child: GuildChannelList(guildId: guildId!)),
      ],
    );
  }
}
