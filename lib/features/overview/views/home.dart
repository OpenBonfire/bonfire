import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/features/overview/views/channel_list.dart';
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
                children: [Sidebar(), Expanded(child: ChannelList())],
              ),
            ),
            main: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  color: Theme.of(context).custom.colorTheme.greyColor1,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    )
                  ]),
            )));
  }
}
