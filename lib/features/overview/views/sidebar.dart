import 'package:bonfire/features/overview/widgets/icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({super.key});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 60,
        height: double.infinity,
        child: Center(
          child: SizedBox(
            width: 50,
            child: ListView(
              children: const [ServerIcon()],
            ),
          ),
        ));
  }
}
