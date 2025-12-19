import 'package:bonfire/shared/components/navigation/overlapping_panels.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:flutter/material.dart';

class AdaptivePanelLayout extends StatelessWidget {
  final Widget? left;
  final Widget? main;
  final Widget? right;
  const AdaptivePanelLayout({super.key, this.left, this.main, this.right});

  @override
  Widget build(BuildContext context) {
    final isMobile = shouldUseMobileLayout(context);
    if (isMobile) {
      return OverlappingPanels(left: main, right: right, main: main);
    }

    return Scaffold(
      body: Row(
        children: [
          if (left != null) Flexible(child: left!),
          if (main != null) Flexible(child: main!),
          if (right != null) Flexible(child: right!),
        ],
      ),
    );
  }
}
