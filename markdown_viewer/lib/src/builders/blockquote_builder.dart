import 'package:flutter/material.dart';

import '../helpers/is_dark_mode.dart';
import '../helpers/parse_block_padding.dart';
import 'builder.dart';

class BlockquoteBuilder extends MarkdownElementBuilder {
  BlockquoteBuilder({
    super.context,
    TextStyle? textStyle,
    this.padding,
    this.contentPadding,
    this.decoration,
  }) : super(
          textStyle: TextStyle(
            color: isDarkMode(context)
                ? const Color(0xff999999)
                : const Color(0xff666666),
          ).merge(textStyle),
        );

  final EdgeInsets? padding;
  final EdgeInsets? contentPadding;
  final BoxDecoration? decoration;

  @override
  final matchTypes = ['blockquote'];

  @override
  Widget? buildWidget(element, parent) {
    final widget = Container(
      width: double.infinity,
      decoration: decoration ??
          BoxDecoration(
            border: Border(
              left: BorderSide(
                color: darkMode
                    ? const Color(0xff777777)
                    : const Color(0xffcccccc),
                width: 5,
              ),
            ),
          ),
      padding: contentPadding ?? const EdgeInsets.only(left: 20),
      child: super.buildWidget(element, parent),
    );

    final parsedPadding = parseBlockPadding(padding, element.element.position);

    if (parsedPadding == null) {
      return widget;
    }

    return Padding(padding: parsedPadding, child: widget);
  }
}
