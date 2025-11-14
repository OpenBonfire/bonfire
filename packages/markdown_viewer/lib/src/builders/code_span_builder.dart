import 'package:flutter/material.dart';
import 'builder.dart';

class CodeSpanBuilder extends MarkdownElementBuilder {
  CodeSpanBuilder({
    super.context,
    TextStyle? textStyle,
  }) : _textStyle = textStyle;

  @override
  final matchTypes = ['codeSpan'];

  double? _lineHeight;
  final TextStyle? _textStyle;

  @override
  TextStyle? buildTextStyle(element, defaultStyle) {
    Color color;
    Color backgroundColor;
    if (darkMode) {
      color = const Color(0Xffca4219);
      backgroundColor = const Color(0Xff424242);
    } else {
      color = const Color(0xff8b1c1c);
      backgroundColor = const Color(0x10000000);
    }

    final style = super.buildTextStyle(element, defaultStyle)?.merge(TextStyle(
          color: color,
          fontFamily: 'monospace',
          backgroundColor: backgroundColor,
        ).merge(_textStyle));
    _lineHeight = style?.height;

    return style?.copyWith(height: 1);
  }

  @override
  Widget? buildWidget(element, parent) {
    final richText = element.children.single as RichText;

    // The purpose of this is to make the RichText has the same line height as
    // it should be while the line height of TextSpan has been changed to 1.
    return renderer.createRichText(
      richText.text as TextSpan,
      strutStyle: StrutStyle(height: _lineHeight, forceStrutHeight: true),
    );
  }
}
