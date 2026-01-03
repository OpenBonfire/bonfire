import 'package:flutter/material.dart';

/// A generic shimmer container that displays a loading shimmer effect.
///
/// This widget can be used to show a placeholder loading state with an animated
/// shimmer effect. It's highly customizable and can be used anywhere in the app.
///
/// Example usage:
/// ```dart
/// ShimmerContainer(
///   width: 200,
///   height: 50,
///   borderRadius: BorderRadius.circular(8),
/// )
/// ```
class ShimmerContainer extends StatefulWidget {
  /// Width of the shimmer container
  final double? width;

  /// Height of the shimmer container
  final double? height;

  /// Border radius of the shimmer container
  final BorderRadius? borderRadius;

  /// Margin around the shimmer container
  final EdgeInsetsGeometry? margin;

  /// Padding inside the shimmer container
  final EdgeInsetsGeometry? padding;

  /// Duration of the shimmer animation
  final Duration duration;

  /// Custom shape for the shimmer container
  final BoxShape? shape;

  final Color? baseColor;

  final Color? highlightColor;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.padding,
    this.duration = const Duration(milliseconds: 1500),
    this.shape,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerContainer> createState() => _ShimmerContainerState();
}

class _ShimmerContainerState extends State<ShimmerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.surfaceContainer;
    final highlightColor =
        widget.highlightColor ?? theme.colorScheme.surfaceContainerHigh;

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: widget.shape == BoxShape.circle
            ? null
            : widget.borderRadius,
        shape: widget.shape ?? BoxShape.rectangle,
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.shape == BoxShape.circle
                  ? null
                  : widget.borderRadius,
              shape: widget.shape ?? BoxShape.rectangle,
              gradient: LinearGradient(
                begin: .topLeft,
                end: .bottomRight,
                colors: [baseColor, highlightColor, baseColor],
                stops: const [0.0, 0.5, 1.0],
                transform: _ShimmerGradientTransform(_animation.value),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom gradient transform for the shimmer effect
class _ShimmerGradientTransform extends GradientTransform {
  final double percent;

  const _ShimmerGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0, 0);
  }
}
