import 'package:flutter/rendering.dart';

import 'definition.dart';

class MarkdownStyle {
  const MarkdownStyle({
    this.textStyle,
    this.headline1,
    this.headline2,
    this.headline3,
    this.headline4,
    this.headline5,
    this.headline6,
    this.h1Padding = const EdgeInsets.only(bottom: 12),
    this.h2Padding = const EdgeInsets.only(bottom: 9),
    this.h3Padding = const EdgeInsets.only(bottom: 6),
    this.h4Padding = const EdgeInsets.only(bottom: 4),
    this.h5Padding = const EdgeInsets.only(bottom: 3),
    this.h6Padding = const EdgeInsets.only(bottom: 3),
    this.paragraph,
    this.paragraphPadding = const EdgeInsets.only(bottom: 12.0),
    this.blockquote,
    this.blockquoteDecoration,
    this.blockquotePadding,
    this.blockquoteContentPadding,
    this.footnoteReferenceDecoration,
    this.footnoteReferencePadding,
    this.dividerColor,
    this.dividerHeight,
    this.dividerThickness,
    this.emphasis,
    this.strongEmphasis,
    this.highlight,
    this.strikethrough,
    this.subscript,
    this.superscript,
    this.kbd,
    this.footnote,
    this.footnoteReference,
    this.link,
    this.codeSpan,
    this.list,
    this.listItem,
    this.listItemMarker,
    this.listItemMarkerTrailingSpace,
    this.listItemMinIndent,
    this.checkbox,
    this.table,
    this.tableHead,
    this.tableBody,
    this.tableBorder,
    this.tableRowDecoration,
    this.tableRowDecorationAlternating,
    this.tableCellPadding,
    this.tableColumnWidth,
    this.codeBlock,
    this.codeblockPadding,
    this.codeblockDecoration,
    this.blockSpacing = 8.0,
    this.copyIconColor,
  });

  final TextStyle? textStyle;
  final TextStyle? headline1;
  final TextStyle? headline2;
  final TextStyle? headline3;
  final TextStyle? headline4;
  final TextStyle? headline5;
  final TextStyle? headline6;
  final EdgeInsets? h1Padding;
  final EdgeInsets? h2Padding;
  final EdgeInsets? h3Padding;
  final EdgeInsets? h4Padding;
  final EdgeInsets? h5Padding;
  final EdgeInsets? h6Padding;
  final TextStyle? paragraph;
  final EdgeInsets? paragraphPadding;
  final TextStyle? blockquote;
  final BoxDecoration? blockquoteDecoration;
  final EdgeInsets? blockquotePadding;
  final EdgeInsets? blockquoteContentPadding;
  final BoxDecoration? footnoteReferenceDecoration;
  final EdgeInsets? footnoteReferencePadding;
  final Color? dividerColor;
  final double? dividerHeight;
  final double? dividerThickness;
  final TextStyle? emphasis;
  final TextStyle? strongEmphasis;
  final TextStyle? highlight;
  final TextStyle? strikethrough;
  final TextStyle? subscript;
  final TextStyle? superscript;
  final TextStyle? kbd;
  final TextStyle? footnote;
  final TextStyle? footnoteReference;
  final TextStyle? link;
  final TextStyle? codeSpan;
  final TextStyle? list;
  final TextStyle? listItem;
  final TextStyle? listItemMarker;
  final double? listItemMarkerTrailingSpace;
  final double? listItemMinIndent;
  final TextStyle? checkbox;
  final TextStyle? table;
  final TextStyle? tableHead;
  final TextStyle? tableBody;
  final TableBorder? tableBorder;
  final BoxDecoration? tableRowDecoration;
  final MarkdownAlternating? tableRowDecorationAlternating;
  final EdgeInsets? tableCellPadding;
  final TableColumnWidth? tableColumnWidth;
  final TextStyle? codeBlock;
  final EdgeInsets? codeblockPadding;
  final BoxDecoration? codeblockDecoration;
  final Color? copyIconColor;

  /// The vertical space between two block elements.
  final double blockSpacing;
}
