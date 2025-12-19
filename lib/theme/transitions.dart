import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

class WebAwareTransitions extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (UniversalPlatform.isWeb) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          if (animation.status == AnimationStatus.forward ||
              animation.status == AnimationStatus.reverse) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                (context as Element).markNeedsBuild();
              }
            });
          }
          return FadeTransition(opacity: animation, child: child);
        },
      );
    }

    return CupertinoPageTransitionsBuilder().buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
