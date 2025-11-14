import 'package:flutter/material.dart';

import '../helpers/parse_block_padding.dart';
import 'builder.dart';

class ParagraphBuilder extends MarkdownElementBuilder {
  ParagraphBuilder({
    super.textStyle,
    this.padding,
  });

  final EdgeInsets? padding;

  @override
  final matchTypes = ['paragraph'];

  @override
  EdgeInsets? blockPadding(element, parent) {
    // When a list is not tight, add padding to list item
    if (parent.type == 'listItem') {
      return null;
    }

    return parseBlockPadding(padding, element.element.position);
  }
}
