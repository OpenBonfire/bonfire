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
        color: Theme.of(context).custom.colorTheme.blurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.folder, size: 30, color: Colors.white),
    );
  }
}
