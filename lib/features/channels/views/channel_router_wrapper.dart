import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChannelRouterWrapper extends ConsumerWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  const ChannelRouterWrapper({
    super.key,
    required this.guildId,
    required this.channelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
