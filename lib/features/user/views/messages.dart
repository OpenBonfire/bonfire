import 'package:bonfire/features/overview/controllers/navigation_bar.dart';
import 'package:bonfire/features/overview/views/navigator.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserMessagesView extends ConsumerStatefulWidget {
  const UserMessagesView({super.key});

  @override
  ConsumerState<UserMessagesView> createState() => _UserMessagesViewState();
}

class _UserMessagesViewState extends ConsumerState<UserMessagesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: PopUpNavigationBar(
            panel: OverlappingPanels(
                onSideChange: (value) {
                  // hide keyboard
                  FocusScope.of(context).unfocus();
                  ref.read(navigationBarProvider.notifier).onSideChange(value);
                },
                left: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Row(
                    children: [Text("hey there"), Text("why hello there :D")],
                  ),
                ),
                main: const Text("bruh"),
                right: const Text("moment"))));
  }
}
