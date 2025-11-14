import 'package:flutter/material.dart';

import 'builder.dart';

class ThematicBreakBuilder extends MarkdownElementBuilder {
  ThematicBreakBuilder({
    this.color,
    this.height,
    this.thickness,
  });

  final Color? color;
  final double? height;
  final double? thickness;

  @override
  final matchTypes = ['thematicBreak'];

  @override
  Widget? buildWidget(element, parent) {
    return Divider(
      color: color,
      height: height,
      thickness: thickness,
    );
  }
}
