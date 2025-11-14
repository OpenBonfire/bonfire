import 'package:flutter/widgets.dart';

import '../ast.dart';

/// A class for for the tree element produced by [MarkdownRenderer].
abstract class MarkdownTreeElement {
  MarkdownTreeElement({
    required this.element,
    this.style,
  });

  final TextStyle? style;

  /// The original [MarkdownElement].
  final MarkdownElement element;

  final List<Widget> children = <Widget>[];

  String get type => element.type;
  bool get isBlock => element.isBlock;
  Map<String, String> get attributes => element.attributes;
}

abstract class MarkdownImageInfo {
  MarkdownImageInfo({
    this.title,
    this.description,
    this.width,
    this.height,
  });

  final String? title;
  final String? description;
  final double? width;
  final double? height;
}
