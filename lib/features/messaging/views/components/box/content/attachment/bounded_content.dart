import 'dart:math';

import 'package:flutter/material.dart';

class BoundedContent extends StatelessWidget {
  final Widget child;
  final double aspectRatio;
  const BoundedContent(
      {super.key, required this.child, required this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = min(constraints.maxWidth, 500);
        double maxHeight = 400;

        double height = maxHeight;
        double width = height * aspectRatio;

        if (width > maxWidth) {
          width = maxWidth;
          height = width / aspectRatio;
        }

        return SizedBox(
          height: height,
          child: AspectRatio(aspectRatio: aspectRatio, child: child),
        );
      },
    );
  }
}
