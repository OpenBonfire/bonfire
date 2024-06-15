import 'package:bonfire/features/overview/views/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Overview extends ConsumerStatefulWidget {
  final Widget childView;
  const Overview({super.key, required this.childView});

  @override
  ConsumerState<Overview> createState() => _OverviewState();
}

class _OverviewState extends ConsumerState<Overview> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.childView,
        const BarWidget(),
      ],
    );
  }
}
