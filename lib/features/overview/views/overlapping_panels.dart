library overlapping_panels;

import 'package:flutter/material.dart';
import 'dart:core';

/// Display sections
enum RevealSide { left, right, main }

/// Widget to display three view panels with the [OverlappingPanels.main] being
/// in the center, [OverlappingPanels.left] and [OverlappingPanels.right] also
/// revealing from their respective sides. Just like you will see in the
/// Discord mobile app's navigation.
class OverlappingPanels extends StatefulWidget {
  /// The left panel
  final Widget? left;

  /// The main panel
  final Widget main;

  /// The right panel
  final Widget? right;

  /// The offset to use to keep the main panel visible when the left or right
  /// panel is revealed.
  final double restWidth;

  /// A callback to notify when a panel reveal has completed.
  final ValueChanged<RevealSide>? onSideChange;

  OverlappingPanels(
      {this.left,
      required this.main,
      this.right,
      this.restWidth = 25,
      this.onSideChange,
      Key? key})
      : super(key: key);

  static OverlappingPanelsState? of(BuildContext context) {
    return context.findAncestorStateOfType<OverlappingPanelsState>();
  }

  @override
  State<StatefulWidget> createState() {
    return OverlappingPanelsState();
  }
}

class OverlappingPanelsState extends State<OverlappingPanels>
    with TickerProviderStateMixin {
  AnimationController? controller;
  double translate = 0;
  int lastDelta = 0;

  void moveToState(RevealSide side) {
    final mediaWidth = MediaQuery.of(context).size.width;
    double goal;

    switch (side) {
      case RevealSide.left:
        goal = _calculateGoal(mediaWidth, 1);
        break;
      case RevealSide.right:
        goal = _calculateGoal(mediaWidth, -1);
        break;
      case RevealSide.main:
      default:
        goal = 0;
        break;
    }

    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    final animation = Tween<double>(
      begin: translate,
      end: goal,
    ).animate(animationController);

    animation.addListener(() {
      setState(() {
        translate = animation.value;
      });
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onSideChange != null) {
          widget.onSideChange!(
            translate == 0
                ? RevealSide.main
                : (translate > 0 ? RevealSide.left : RevealSide.right),
          );
        }
        animationController.dispose();
      }
    });

    animationController.forward();
  }

  double _calculateGoal(double width, int multiplier) {
    return (multiplier * width) + (-multiplier * widget.restWidth);
  }

  void _onApplyTranslation() {
    final mediaWidth = MediaQuery.of(context).size.width;

    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );

    var goal = 0.0;
    if (lastDelta > 0) {
      goal = _calculateGoal(mediaWidth, 1);
    }

    if (lastDelta < 0) {
      goal = _calculateGoal(mediaWidth, -1);
    }

    if (lastDelta > 0 && translate < 0) {
      goal = 0;
    }

    if (lastDelta < 0 && translate > 0) {
      goal = 0;
    }

    final animation = Tween<double>(
      begin: translate,
      end: goal.toDouble(),
    ).animate(animationController);

    animation.addListener(() {
      setState(() {
        translate = animation.value;
      });
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onSideChange != null) {
          widget.onSideChange!(
            translate == 0
                ? RevealSide.main
                : (translate > 0 ? RevealSide.left : RevealSide.right),
          );
        }
        animationController.dispose();
      }
    });

    animationController.forward();
  }

  void reveal(RevealSide direction) {
    // can only reveal when showing main
    if (translate != 0) {
      return;
    }

    final mediaWidth = MediaQuery.of(context).size.width;

    final multiplier = (direction == RevealSide.left ? 1 : -1);
    final goal = _calculateGoal(mediaWidth, multiplier);

    final animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onApplyTranslation();
        animationController.dispose();
      }
    });

    final animation =
        Tween<double>(begin: translate, end: goal).animate(animationController);

    animation.addListener(() {
      setState(() {
        translate = animation.value;
      });
    });

    animationController.forward();
  }

  void onTranslate(double delta) {
    setState(() {
      final translate = this.translate + delta;
      if (translate < 0 && widget.right != null ||
          translate > 0 && widget.left != null) {
        this.translate = translate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Offstage(
        offstage: translate < 0,
        child: widget.left,
      ),
      Offstage(
        offstage: translate > 0,
        child: widget.right,
      ),
      Transform.translate(
        offset: Offset(translate, 0),
        child: widget.main,
      ),
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          lastDelta = details.delta.dx.toInt();
          onTranslate(details.delta.dx);
        },
        onHorizontalDragEnd: (details) {
          _onApplyTranslation();
        },
      ),
    ]);
  }
}
