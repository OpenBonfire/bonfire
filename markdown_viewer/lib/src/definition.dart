import 'package:dart_markdown/dart_markdown.dart' as md;
import 'package:flutter/material.dart';

import 'models/markdown_tree_element.dart';

/// Enumeration of the ways to alternate the table row background.
enum MarkdownAlternating { odd, even }

/// Enumeration of list types.
enum MarkdownListType { ordered, unordered }

/// Signature for callbacks used by [MarkdownWidget] when the user taps a link.
typedef MarkdownTapLinkCallback = void Function(
  String? href,
  String? title,
);

/// Signature for custom list item marker widget.
typedef MarkdownListItemMarkerBuilder = Widget Function(
  MarkdownListType style,
  String? number,
);

/// Signature for custom checkbox widget.
typedef MarkdownCheckboxBuilder = Widget Function(bool checked);

/// Alias name of BlockSyntax from dart_markdown package.
typedef MdBlockSyntax = md.BlockSyntax;

/// Alias name of InlineSyntax from dart_markdown package.
typedef MdInlineSyntax = md.InlineSyntax;

/// Alias name of Node from dart_markdown package.
typedef MdNode = md.Node;

/// Alias name of InlineObject from dart_markdown package.
typedef MdInlineObject = md.InlineObject;

/// Alias name of InlineElement from dart_markdown package.
typedef MdInlineElement = md.InlineElement;

/// Alias name of Element from dart_markdown package.
typedef MdElement = md.Element;

/// Alias name of BlockElement from dart_markdown package.
typedef MdBlockElement = md.BlockElement;

/// Alias name of Text from dart_markdown package.
typedef MdText = md.Text;

/// Alias name of InlineParser from dart_markdown package.
typedef MdInlineParser = md.InlineParser;

/// Alias name of BlockParser from dart_markdown package.
typedef MdBlockParser = md.BlockParser;

/// Signature for custom image widget.
typedef MarkdownImageBuilder = Widget Function(Uri uri, MarkdownImageInfo info);

/// Syntax highlights [text] for codeBlock element.
typedef MarkdownHighlightBuilder = List<TextSpan> Function(
  String text,
  String? language,
  String? infoString,
);

typedef CopyIconBuilder = Widget Function(bool copied);
