import 'dart:ui';
import 'package:flutter/material.dart';

import '../helpers/is_dark_mode.dart';
import 'builder.dart';

class SimpleInlinesBuilder extends MarkdownElementBuilder {
  SimpleInlinesBuilder({
    super.context,
    TextStyle? emphasis,
    TextStyle? strongEmphasis,
    TextStyle? highlight,
    TextStyle? strikethrough,
    TextStyle? subscript,
    TextStyle? superscript,
    TextStyle? kbd,
  }) : super(textStyleMap: {
          'emphasis': const TextStyle(
            fontStyle: FontStyle.italic,
          ).merge(emphasis),
          'strongEmphasis': const TextStyle(
            fontWeight: FontWeight.w700,
          ).merge(strongEmphasis),
          'highlight': TextStyle(
            backgroundColor: isDarkMode(context)
                ? const Color(0xffffbb00)
                : const Color(0xffffee00),
          ).merge(highlight),
          'strikethrough': const TextStyle(
            color: Color(0xffff6666),
            decoration: TextDecoration.lineThrough,
          ).merge(strikethrough),
          'subscript': const TextStyle(
            fontFeatures: [FontFeature.subscripts()],
          ).merge(subscript),
          'superscript': const TextStyle(
            fontFeatures: [FontFeature.superscripts()],
          ).merge(superscript),
          'kbd': kbd,
        });

  @override
  TextSpan? createText(element, parentStyle) {
    if (element.type != 'hardLineBreak') {
      return null;
    }

    return TextSpan(text: '\n', style: parentStyle);
  }

  @override
  final matchTypes = [
    'emphasis',
    'strongEmphasis',
    'link',
    'hardLineBreak',
    'highlight',
    'strikethrough',
    'emoji',
    'superscript',
    'subscript',
    'kbd',
    'rawHtml',
  ];
}
