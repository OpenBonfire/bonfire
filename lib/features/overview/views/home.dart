import 'package:bonfire/features/channels/views/channels.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/features/messaging/views/messages.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:bonfire/features/overview/views/sidebar.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OverlappingPanels(
            left: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Row(
                children: [Sidebar(), Expanded(child: ChannelsList())],
              ),
            ),
            main: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: OverlappingPanels(
                  main: const MessageView(),
                  right: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ))));
  }
}
