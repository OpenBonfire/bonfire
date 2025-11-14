import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';

class FolderIcon extends StatelessWidget {
  final Color color;

  const FolderIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: BonfireThemeExtension.of(context).foreground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.folder, size: 30, color: color),
    );
  }
}
