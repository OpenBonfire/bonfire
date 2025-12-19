import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuildChannelScreen extends ConsumerWidget {
  final Snowflake guildId;
  final Snowflake? channelId;
  const GuildChannelScreen({super.key, required this.guildId, this.channelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
