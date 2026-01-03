import 'package:flutter/material.dart';

class SidebarItem extends StatefulWidget {
  final bool selected;
  final Widget child;
  const SidebarItem({super.key, required this.selected, required this.child});

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 55, width: 55, child: widget.child);
  }
}
