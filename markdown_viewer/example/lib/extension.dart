import 'package:flutter/material.dart';
import 'package:markdown_viewer/markdown_viewer.dart';

/// An example of creating a syntax extension.
class ExampleSyntax extends MdInlineSyntax {
  ExampleSyntax() : super(RegExp(r'#[^#]+?(?=\s+|$)'));

  @override
  MdInlineObject? parse(MdInlineParser parser, Match match) {
    final markers = [parser.consume()];
    final content = parser.consumeBy(match[0]!.length - 1);
    final children = content.map((e) => MdText.fromSpan(e)).toList();

    return MdInlineElement(
      'example',
      markers: markers,
      children: children,
      start: markers.first.start,
      end: children.last.end,
    );
  }
}

/// An example of creating a element builder.
class ExampleBuilder extends MarkdownElementBuilder {
  ExampleBuilder()
      : super(
          textStyle: const TextStyle(
            color: Colors.green,
            decoration: TextDecoration.underline,
          ),
        );

  @override
  bool isBlock(element) => false;

  @override
  List<String> matchTypes = <String>['example'];
}
