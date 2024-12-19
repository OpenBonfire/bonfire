import 'package:dart_markdown/dart_markdown.dart' as md;

import 'extensions.dart';

abstract class NodeVisitor extends md.Visitor<MarkdownText, MarkdownElement> {}

/// Base class for Markdown nodes.
abstract class MarkdownNode {
  const MarkdownNode();
  void accept(NodeVisitor visitor);
  Map<String, dynamic> toMap();

  /// The position of this node in it's siblings.
  SiblingPosition get position;
}

/// Creates a [MarkdownElement] node.
class MarkdownElement extends MarkdownNode {
  const MarkdownElement(
    this.type,
    this.position, {
    required this.isBlock,
    this.children = const [],
    this.attributes = const {},
  });

  MarkdownElement.root(this.children)
      : type = '',
        attributes = const {},
        position = SiblingPosition(index: 0, total: 1),
        isBlock = true;

  final String type;
  final bool isBlock;
  final List<MarkdownNode> children;
  final Map<String, String> attributes;
  bool get isRoot => type.isEmpty;

  @override
  final SiblingPosition position;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'position': position.toMap(),
        if (children.isNotEmpty)
          'children': children.map((e) => e.toMap()).toList(),
        if (attributes.isNotEmpty) 'attributes': attributes,
      };

  @override
  String toString() => toMap().toPrettyString();

  @override
  void accept(NodeVisitor visitor) {
    if (visitor.visitElementBefore(this)) {
      if (children.isNotEmpty) {
        for (final child in children) {
          child.accept(visitor);
        }
      }
      visitor.visitElementAfter(this);
    }
  }
}

/// Creates a [MarkdownText] node.
class MarkdownText extends MarkdownNode {
  const MarkdownText(this.text, this.position);
  final String text;

  @override
  Map<String, dynamic> toMap() => {
        'text': text,
        'position': position.toMap(),
      };

  @override
  String toString() => toMap().toPrettyString();

  @override
  final SiblingPosition position;

  @override
  void accept(NodeVisitor visitor) => visitor.visitText(this);
}

/// Creates a [SiblingPosition] which represent the postion of a [MarkdownNode]
/// in it's siblings.
class SiblingPosition {
  SiblingPosition({
    this.total = 0,
    this.index = 0,
  });

  int total;
  int index;

  Map<String, dynamic> toMap() => {'index': index, 'total': total};
}
