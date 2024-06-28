import 'package:bonfire/features/overview/views/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationFrame extends ConsumerStatefulWidget {
  final Widget child;
  const NavigationFrame({super.key, required this.child});

  @override
  ConsumerState<NavigationFrame> createState() => _OverviewState();
}

class _OverviewState extends ConsumerState<NavigationFrame> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        const NavigationBarWidget(),
      ],
    );
  }
}
