import 'ast.dart';
import 'definition.dart';

/// Transform the Markdown AST to the AST fits for Flutter usage.
class AstTransformer {
  AstTransformer();

  final _typeMap = {
    'atxHeading': 'headline',
    'setextHeading': 'headline',
    'fencedCodeBlock': 'codeBlock',
    'indentedCodeBlock': 'codeBlock',
    'fencedBlockquote': 'blockquote',
    'autolinkExtension': 'link',
    'autolink': 'link',
  };

  final _footnoteReferences = <MdElement>[];

  void _updatePosition(List<MarkdownNode> nodes) {
    for (var i = 0; i < nodes.length; i++) {
      nodes[i].position.index = i;
      nodes[i].position.total = nodes.length;
    }
  }

  List<MarkdownNode> transform(List<MdNode> nodes) {
    final result = _iterateNodes(nodes);

    if (_footnoteReferences.isNotEmpty) {
      result.add(_buildFootnoteReference());
    }

    _updatePosition(result);

    return result;
  }

  List<MarkdownNode> _iterateNodes(List<MdNode> nodes) {
    final result = <MarkdownNode>[];

    // Merge the adjacent Text nodes into one.
    final stringBuffer = StringBuffer();

    void popBuffer() {
      if (stringBuffer.isNotEmpty) {
        result.add(MarkdownText(stringBuffer.toString(), SiblingPosition()));
        stringBuffer.clear();
      }
    }

    for (final node in nodes) {
      if (node is MdText) {
        stringBuffer.write(node.textContent);
      } else if (node is MdElement) {
        if ([
          'blankLine',
          'linkReferenceDefinition',
          'footnoteReference',
        ].contains(node.type)) {
          if (node.attributes['number'] != null) {
            _footnoteReferences.add(node);
          }

          continue;
        }

        if (node.type == 'emoji') {
          stringBuffer.write(node.attributes['emoji']);
          continue;
        }

        popBuffer();
        final children = _iterateNodes(node.children);
        _updatePosition(children);
        result.add(MarkdownElement(
          _typeMap[node.type] ?? node.type,
          SiblingPosition(),
          isBlock: node.isBlock,
          attributes: node.attributes,
          children: children,
        ));
      } else {
        throw ArgumentError(
          'Unknown Markdown AST node type ${node.runtimeType}',
        );
      }
    }
    popBuffer();

    return result;
  }

  MarkdownElement _buildFootnoteReference() {
    _footnoteReferences.sort(
      (a, b) => a.attributes['number']!.compareTo(b.attributes['number']!),
    );

    final listItem = _footnoteReferences.map((e) {
      final children = _iterateNodes(e.children);
      _updatePosition(children);
      return MarkdownElement(
        'listItem',
        SiblingPosition(),
        isBlock: e.isBlock,
        attributes: {'number': e.attributes['number']!},
        children: children,
      );
    }).toList();

    return MarkdownElement(
      'footnoteReference',
      SiblingPosition(),
      children: [
        MarkdownElement(
          'orderedList',
          SiblingPosition(),
          isBlock: true,
          children: listItem,
        )
      ],
      isBlock: true,
    );
  }
}
