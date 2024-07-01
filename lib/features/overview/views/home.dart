import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/repositories/events/realtime_messages.dart';
import 'package:bonfire/features/overview/views/home_desktop.dart';
import 'package:bonfire/features/overview/views/home_mobile.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;

class GuildMessagingOverview extends ConsumerStatefulWidget {
  final Snowflake guildId;
  final Snowflake channelId;
  const GuildMessagingOverview(
      {super.key, required this.guildId, required this.channelId});

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.watch(realtimeMessagesProvider).when(
          data: (value) {
            ref
                .read(
                    messagesProvider(widget.guildId, widget.channelId).notifier)
                .processRealtimeMessages(value);
          },
          loading: () {},
          error: (error, stackTrace) {
            // trust me bro
          });
    });

    return (Platform.isAndroid || Platform.isIOS)
        ? HomeMobile(
            guildId: widget.guildId,
            channelId: widget.channelId,
          )
        : HomeDesktop(
            guildId: widget.guildId,
            channelId: widget.channelId,
          );
  }
}
