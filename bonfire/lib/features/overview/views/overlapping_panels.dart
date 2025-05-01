library overlapping_panels;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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

  /// The duration of the reveal animation
  final Duration revealDuration;

  /// The curve of the reveal animation
  final Curve revealCurve;

  /// The duration of the snap-back animation
  final Duration snapBackDuration;

  /// The curve of the snap-back animation
  final Curve snapBackCurve;

  const OverlappingPanels({
    super.key,
    this.left,
    required this.main,
    this.right,
    this.restWidth = 25,
    this.onSideChange,
    this.revealDuration = const Duration(milliseconds: 300),
    this.revealCurve = Curves.easeOutCubic,
    this.snapBackDuration = const Duration(milliseconds: 250),
    this.snapBackCurve = Curves.easeOutCubic,
  });

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
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _translate = 0;
  int _lastDelta = 0;
  int _lastLastDelta = 0;
  bool _ignoreGestures = false;
  late HorizontalDragGestureRecognizer _panelDragRecognizer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.revealDuration,
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.revealCurve,
      ),
    );
    _animation.addListener(_updateTranslate);
    _panelDragRecognizer = HorizontalDragGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _panelDragRecognizer.dispose();
    super.dispose();
  }

  void _updateTranslate() {
    setState(() {
      _translate = _animation.value;
    });
  }

  void moveToState(RevealSide side) {
    final mediaWidth = MediaQuery.sizeOf(context).width;
    double goal;

    switch (side) {
      case RevealSide.left:
        goal = _calculateGoal(mediaWidth, 1);
        break;
      case RevealSide.right:
        goal = _calculateGoal(mediaWidth, -1);
        break;
      case RevealSide.main:
        goal = 0;
        break;
    }

    _animateToPosition(goal, widget.revealDuration, widget.revealCurve);
  }

  double _calculateGoal(double width, int multiplier) {
    return (multiplier * width) + (-multiplier * widget.restWidth);
  }

  void _onApplyTranslation() {
    final mediaWidth = MediaQuery.sizeOf(context).width;

    double averagedDelta = (_lastDelta + _lastLastDelta) / 2;

    var goal = 0.0;
    if (averagedDelta > 0) {
      goal = _calculateGoal(mediaWidth, 1);
    }

    if (averagedDelta < 0) {
      goal = _calculateGoal(mediaWidth, -1);
    }

    if (averagedDelta > 0 && _translate < 0) {
      goal = 0;
    }

    if (averagedDelta < 0 && _translate > 0) {
      goal = 0;
    }

    _animateToPosition(goal, widget.snapBackDuration, widget.snapBackCurve);
  }

  void _animateToPosition(double goal, Duration duration, Curve curve) {
    _animationController.stop();
    _animationController.duration = duration;
    _animation = Tween<double>(
      begin: _translate,
      end: goal,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: curve,
    ));
    _animation.addStatusListener(_onAnimationComplete);
    _animationController.forward(from: 0);
  }

  void _onAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _animation.removeStatusListener(_onAnimationComplete);
      if (widget.onSideChange != null) {
        widget.onSideChange!(
          _translate == 0
              ? RevealSide.main
              : (_translate > 0 ? RevealSide.left : RevealSide.right),
        );
      }
    }
  }

  void reveal(RevealSide direction) {
    final mediaWidth = MediaQuery.sizeOf(context).width;
    final multiplier = (direction == RevealSide.left ? 1 : -1);
    final goal = _calculateGoal(mediaWidth, multiplier);
    _animateToPosition(goal, widget.revealDuration, widget.revealCurve);
  }

  void onTranslate(double delta) {
    setState(() {
      final newTranslate = _translate + delta;
      if (newTranslate < 0 && widget.right != null ||
          newTranslate > 0 && widget.left != null) {
        _translate = newTranslate;
      }
    });
  }

  void setIgnoreGestures(bool ignore) {
    setState(() {
      _ignoreGestures = ignore;
    });
  }

  void _handleDragStart(DragStartDetails details) {
    if (!_ignoreGestures) {
      // Start of panel drag
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_ignoreGestures) {
      _lastLastDelta = _lastDelta;
      _lastDelta = details.delta.dx.toInt();
      onTranslate(details.delta.dx);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_ignoreGestures) {
      _onApplyTranslation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            HorizontalDragGestureRecognizer>(
          () => _panelDragRecognizer,
          (_) {},
        ),
      },
      child: Stack(children: [
        Offstage(
          offstage: _translate < 0,
          child: widget.left,
        ),
        Offstage(
          offstage: _translate > 0,
          child: widget.right,
        ),
        Transform.translate(
          offset: Offset(_translate, 0),
          child: widget.main,
        ),
      ]),
    );
  }
}
