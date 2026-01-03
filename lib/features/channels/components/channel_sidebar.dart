import 'package:bonfire/features/guilds/components/sidebar/sidebar.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelSidebar extends ConsumerWidget {
  final Snowflake? guildId;
  final Snowflake? channelId;

  const ChannelSidebar({super.key, this.guildId, this.channelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(children: [SizedBox(width: 60, child: GuildSidebar())]);
  }
}
