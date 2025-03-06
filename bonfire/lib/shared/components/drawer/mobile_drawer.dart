import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:rubber/rubber.dart';

class GlobalDrawer extends StatefulWidget {
  final Widget child;

  const GlobalDrawer({super.key, required this.child});

  static GlobalDrawerState? of(BuildContext context) {
    return context.findAncestorStateOfType<GlobalDrawerState>();
  }

  @override
  GlobalDrawerState createState() => GlobalDrawerState();
}

class GlobalDrawerState extends State<GlobalDrawer>
    with SingleTickerProviderStateMixin {
  late RubberAnimationController _controller;
  Widget? child;

  @override
  void initState() {
    super.initState();
    _controller = RubberAnimationController(
      initialValue: 0,
      dismissable: true,
      duration: const Duration(milliseconds: 300),
      upperBoundValue: AnimationControllerValue(percentage: 0.7),
      vsync: this,
    );
  }

  void toggleDrawer() {
    setState(() {
      if (_controller.value == 0) {
        _controller.expand();
      } else {
        _controller.collapse();
      }
    });
  }

  void setChild(Widget child) {
    setState(() {
      this.child = child;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          RubberBottomSheet(
            lowerLayer: Container(),
            upperLayer: Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).custom.colorTheme.background,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
            animationController: _controller,
          ),
        ],
      ),
    );
  }
}
