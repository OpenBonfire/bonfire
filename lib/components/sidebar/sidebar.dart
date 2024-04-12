import 'package:flutter/material.dart';
import 'package:guildcable/components/sidebar/icon.dart';
import 'package:guildcable/style.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: double.infinity,
      decoration:
          BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: ListView(
        children: const [ServerIcon()],
      ),
    );
  }
}
