import 'dart:ui';
import 'package:flutter/material.dart';

import 'builder.dart';

class FootnoteBuilder extends MarkdownElementBuilder {
  FootnoteBuilder({
    TextStyle? footnote,
    TextStyle? footnoteReference,
    this.footnoteReferenceDecoration,
    this.footnoteReferencePadding,
  })  : _footnoteStyle = footnote,
        super(textStyleMap: {
          'footnoteReference': footnoteReference,
        });

  final TextStyle? _footnoteStyle;
  BoxDecoration? footnoteReferenceDecoration;
  EdgeInsets? footnoteReferencePadding;

  @override
  final matchTypes = [
    'footnote',
    'footnoteReference',
  ];

  @override
  Widget? buildWidget(element, parent) {
    if (element.type == 'footnote') {
      return Text(
        element.attributes['number']!,
        style: const TextStyle(
          fontFeatures: [FontFeature.superscripts()],
        ).merge(_footnoteStyle),
      );
    }
    final child = element.children.single;
    if (footnoteReferenceDecoration == null &&
        footnoteReferencePadding == null) {
      return child;
    }

    return Container(
      decoration: footnoteReferenceDecoration,
      padding: footnoteReferencePadding,
      child: child,
    );
  }
}
