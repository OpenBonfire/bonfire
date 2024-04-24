import 'package:bonfire/features/overview/controllers/navigation_bar.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopUpNavigationBar extends StatefulWidget {
  final OverlappingPanels panel;
  const PopUpNavigationBar({Key? key, required this.panel}) : super(key: key);

  @override
  _PopUpNavigationBarState createState() => _PopUpNavigationBarState();
}

class _PopUpNavigationBarState extends State<PopUpNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.panel,
        BarWidget(
          panel: widget.panel,
        )
      ],
    );
  }
}

class BarWidget extends ConsumerStatefulWidget {
  final OverlappingPanels panel;
  const BarWidget({Key? key, required this.panel}) : super(key: key);

  @override
  ConsumerState<BarWidget> createState() => _BarWidgetState();
}

class _BarWidgetState extends ConsumerState<BarWidget> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(navigationBarProvider);

    if (state == RevealSide.left) {
      visible = true;
    } else {
      visible = false;
    }
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      bottom: visible ? 0 : -80,
      left: 0,
      right: 0,
      curve: Curves.easeInOutExpo,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeInOut,
        )),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.brightestGray,
          ),
          height: 80,
        ),
      ),
    );
  }
}
