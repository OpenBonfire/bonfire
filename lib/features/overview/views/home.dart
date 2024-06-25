import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/repositories/events/realtime_messages.dart';
import 'package:bonfire/features/overview/controllers/navigation_bar.dart';
import 'package:bonfire/features/overview/views/home_desktop.dart';
import 'package:bonfire/features/overview/views/home_mobile.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeScreen> {
  RevealSide selfPanelState = RevealSide.main;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // TODO: Make this less hacky
      /*
        This works because there's a bug on initstate for the panels.
        When the panels are initialized *at all*, they will return to the
        `right` state. I think this may break once that is fixed.

        Currently, we don't even need `selfPanelState`, we could actually
        just guess the `right` state and be correct.
      */
      ref.read(navigationBarProvider.notifier).onSideChange(selfPanelState);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.watch(realtimeMessagesProvider).when(
          data: (value) {
            ref.read(messagesProvider.notifier).processRealtimeMessages(value);
          },
          loading: () {},
          error: (error, stackTrace) {
            // trust me bro
          });
    });

    return (Platform.isAndroid || Platform.isIOS)
        ? const HomeMobile()
        : const HomeDesktop();
  }
}
