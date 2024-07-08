import 'package:bonfire/features/me/views/components/messages.dart';
import 'package:bonfire/features/me/views/platforms/desktop.dart';
import 'package:bonfire/features/overview/views/sidebar.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_platform/universal_platform.dart';

class MessageOverview extends ConsumerStatefulWidget {
  const MessageOverview({super.key});

  @override
  ConsumerState<MessageOverview> createState() => _MessageOverviewState();
}

class _MessageOverviewState extends ConsumerState<MessageOverview> {
  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isDesktop) {
      return const Row(
        children: [
          Sidebar(guildId: Snowflake.zero),
          Expanded(child: PrivateMessages()),
        ],
      );
    } else {
      return const PrivateMessages();
    }
  }
}
