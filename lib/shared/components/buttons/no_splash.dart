import 'package:flutter/material.dart';

class NoSplashButton extends StatelessWidget {
  final Widget? child;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final void Function()? onSecondaryTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius borderRadius;
  final bool enabled;
  const NoSplashButton({
    super.key,
    this.onPressed,
    this.onLongPress,
    this.onSecondaryTap,
    this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius = BorderRadius.zero,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius;

    return ClipRRect(
      borderRadius: radius,
      child: IntrinsicWidth(
        child: Material(
          borderRadius: radius,
          color: backgroundColor,

          child: Container(
            decoration: BoxDecoration(
              border: borderColor != null
                  ? Border.all(width: borderWidth ?? 1.0, color: borderColor!)
                  : null,
              borderRadius: radius,
            ),
            child: InkWell(
              onTap: enabled ? onPressed : null,
              onLongPress: enabled ? onLongPress : null,
              onSecondaryTap: enabled ? onSecondaryTap : null,
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
