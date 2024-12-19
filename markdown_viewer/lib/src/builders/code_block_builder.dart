import 'package:flutter/material.dart';

import '../definition.dart';
import '../helpers/is_dark_mode.dart';
import '../widgets/copy_button.dart';
import 'builder.dart';

class CodeBlockBuilder extends MarkdownElementBuilder {
  CodeBlockBuilder({
    TextStyle? textStyle,
    super.context,
    this.padding,
    this.decoration,
    this.highlightBuilder,
    this.copyIconBuilder,
    this.copyIconColor,
  }) : super(
            textStyle: TextStyle(
          color: isDarkMode(context)
              ? const Color(0xffcccccc)
              : const Color(0xff333333),
        ).merge(textStyle));

  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  final MarkdownHighlightBuilder? highlightBuilder;
  final CopyIconBuilder? copyIconBuilder;
  final Color? copyIconColor;

  @override
  final matchTypes = ['codeBlock'];

  @override
  bool replaceLineEndings(String type) => false;

  @override
  TextAlign textAlign(parent) => TextAlign.start;

  @override
  TextSpan buildText(text, parent) {
    final textContent = text.trimRight();
    final style = const TextStyle(fontFamily: 'monospace').merge(parent.style);

    if (highlightBuilder == null) {
      return TextSpan(
        text: textContent,
        style: style,
        mouseCursor: renderer.mouseCursor,
      );
    }

    final spans = highlightBuilder!(
      textContent,
      parent.attributes['language'],
      parent.attributes['infoString'],
    );

    if (spans.isEmpty) {
      return const TextSpan(text: '');
    }

    return TextSpan(
        children: spans, style: style, mouseCursor: renderer.mouseCursor);
  }

  @override
  Widget buildWidget(element, parent) {
    Color backgroundColor;
    if (darkMode) {
      backgroundColor = const Color(0xff101010);
    } else {
      backgroundColor = const Color(0xfff0f0f0);
    }

    const defaultPadding = EdgeInsets.all(15.0);
    final defaultDecoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(5),
    );

    Widget child;
    if (element.children.isNotEmpty) {
      final textWidget = element.children.single;
      child = Stack(
        children: [
          Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: padding ?? defaultPadding,
              child: textWidget,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: CopyButton(
              textWidget,
              iconColor: copyIconColor,
              iconBuilder: copyIconBuilder,
            ),
          ),
        ],
      );
    } else {
      child = const SizedBox(height: 15);
    }

    return Container(
      width: double.infinity,
      decoration: decoration ?? defaultDecoration,
      child: child,
    );
  }
}
