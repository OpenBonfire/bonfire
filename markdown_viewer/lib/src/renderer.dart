import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'ast.dart';
import 'builders/blockquote_builder.dart';
import 'builders/builder.dart';
import 'builders/code_block_builder.dart';
import 'builders/code_span_builder.dart';
import 'builders/footnote_builder.dart';
import 'builders/headline_builder.dart';
import 'builders/image_builder.dart';
import 'builders/link_builder.dart';
import 'builders/list_builder.dart';
import 'builders/paragraph_builder.dart';
import 'builders/simple_inlines_builder.dart';
import 'builders/table_builder.dart';
import 'builders/thematic_break_builder.dart';
import 'definition.dart';
import 'extensions.dart';
import 'helpers/inline_wraper.dart';
import 'helpers/merge_rich_text.dart';
import 'models/markdown_tree_element.dart';
import 'style.dart';
import 'transformer.dart';

class MarkdownRenderer implements NodeVisitor {
  MarkdownRenderer({
    BuildContext? context,
    required MarkdownStyle styleSheet,
    MarkdownTapLinkCallback? onTapLink,
    MarkdownListItemMarkerBuilder? listItemMarkerBuilder,
    MarkdownCheckboxBuilder? checkboxBuilder,
    MarkdownHighlightBuilder? highlightBuilder,
    MarkdownImageBuilder? imageBuilder,
    bool enableImageSize = false,
    List<MarkdownElementBuilder> elementBuilders = const [],
    TextAlign? textAlign,
    Color? selectionColor,
    SelectionRegistrar? selectionRegistrar,
    CopyIconBuilder? copyIconBuilder,
  })  : _selectionColor = selectionColor,
        _selectionRegistrar = selectionRegistrar,
        _blockSpacing = styleSheet.blockSpacing,
        _styleSheet = styleSheet,
        _defaultTextStyle = TextStyle(
          fontSize: 16,
          height: 1.5,
          color: (context != null
                  ? Theme.of(context).textTheme.bodyMedium?.color
                  : null) ??
              const Color(0xff333333),
        ),
        _textAlign = textAlign ?? TextAlign.start {
    final defaultBuilders = [
      HeadlineBuilder(
        headline1: styleSheet.headline1,
        headline2: styleSheet.headline2,
        headline3: styleSheet.headline3,
        headline4: styleSheet.headline4,
        headline5: styleSheet.headline5,
        headline6: styleSheet.headline6,
        h1Padding: styleSheet.h1Padding,
        h2Padding: styleSheet.h2Padding,
        h3Padding: styleSheet.h3Padding,
        h4Padding: styleSheet.h4Padding,
        h5Padding: styleSheet.h5Padding,
        h6Padding: styleSheet.h6Padding,
      ),
      SimpleInlinesBuilder(
        context: context,
        emphasis: styleSheet.emphasis,
        strongEmphasis: styleSheet.strongEmphasis,
        highlight: styleSheet.highlight,
        strikethrough: styleSheet.strikethrough,
        subscript: styleSheet.subscript,
        superscript: styleSheet.superscript,
        kbd: styleSheet.kbd,
      ),
      ThematicBreakBuilder(
        color: styleSheet.dividerColor,
        height: styleSheet.dividerHeight,
        thickness: styleSheet.dividerThickness,
      ),
      ParagraphBuilder(
        textStyle: styleSheet.paragraph,
        padding: styleSheet.paragraphPadding,
      ),
      CodeSpanBuilder(context: context, textStyle: styleSheet.codeSpan),
      LinkBuilder(textStyle: styleSheet.link, onTap: onTapLink),
      TableBuilder(
        table: styleSheet.table,
        tableHead: styleSheet.tableHead,
        tableBody: styleSheet.tableBody,
        tableBorder: styleSheet.tableBorder,
        tableRowDecoration: styleSheet.tableRowDecoration,
        tableRowDecorationAlternating: styleSheet.tableRowDecorationAlternating,
        tableCellPadding: styleSheet.tableCellPadding,
        tableColumnWidth: styleSheet.tableColumnWidth,
      ),
      ImageBuilder(
        imageBuilder: imageBuilder,
        enableImageSize: enableImageSize,
      ),
      CodeBlockBuilder(
        context: context,
        textStyle: styleSheet.codeBlock,
        padding: styleSheet.codeblockPadding,
        decoration: styleSheet.codeblockDecoration,
        highlightBuilder: highlightBuilder,
        copyIconBuilder: copyIconBuilder,
        copyIconColor: styleSheet.copyIconColor,
      ),
      BlockquoteBuilder(
        context: context,
        textStyle: styleSheet.blockquote,
        decoration: styleSheet.blockquoteDecoration,
        padding: styleSheet.blockquotePadding,
        contentPadding: styleSheet.blockquoteContentPadding,
      ),
      ListBuilder(
        list: styleSheet.list,
        listItem: styleSheet.listItem,
        listItemMarker: styleSheet.listItemMarker,
        listItemMarkerTrailingSpace: styleSheet.listItemMarkerTrailingSpace,
        listItemMinIndent: styleSheet.listItemMinIndent,
        checkbox: styleSheet.checkbox,
        listItemMarkerBuilder: listItemMarkerBuilder,
        paragraphPadding: styleSheet.paragraphPadding,
        checkboxBuilder: checkboxBuilder,
      ),
      FootnoteBuilder(
        footnote: styleSheet.footnote,
        footnoteReference: styleSheet.footnoteReference,
        footnoteReferenceDecoration: styleSheet.footnoteReferenceDecoration,
        footnoteReferencePadding: styleSheet.footnoteReferencePadding,
      ),
    ];

    for (final builder in [...defaultBuilders, ...elementBuilders]) {
      for (final type in builder.matchTypes) {
        _builders[type] = builder..register(this);
      }
    }
  }

  final TextAlign _textAlign;
  final double _blockSpacing;
  final Color? _selectionColor;
  final SelectionRegistrar? _selectionRegistrar;
  final MarkdownStyle _styleSheet;
  final TextStyle _defaultTextStyle;

  bool get selectable => _selectionColor != null && _selectionRegistrar != null;
  MouseCursor? get mouseCursor => selectable ? SystemMouseCursors.text : null;

  String? _keepLineEndingsWhen;
  final _gestureRecognizers = <String, GestureRecognizer>{};

  final _tree = <_TreeElement>[];
  final _builders = <String, MarkdownElementBuilder>{};

  List<Widget> render(List<MdNode> nodes) {
    _tree.clear();
    _keepLineEndingsWhen = null;
    _gestureRecognizers.clear();

    final rootChildren = <MarkdownNode>[];
    _tree.add(_TreeElement.root(rootChildren));

    for (final MarkdownNode node in AstTransformer().transform(nodes)) {
      assert(_tree.length == 1);
      rootChildren.add(node);
      node.accept(this);
    }

    assert(_keepLineEndingsWhen == null);
    assert(_gestureRecognizers.isEmpty);
    return _tree.single.children;
  }

  @override
  bool visitElementBefore(MarkdownElement element) {
    final type = element.type;
    assert(_builders[type] != null, "No $type builder found");

    final parentTreeElement = _tree.last;
    final builder = _builders[type]!;
    builder.init(element);

    builder.parentStyle = parentTreeElement.style;
    if (builder.replaceLineEndings(type) == false) {
      _keepLineEndingsWhen = type;
    }
    _gestureRecognizers.addIfNotNull(
      type,
      builder.gestureRecognizer(element),
    );

    final defaultTextStyle = _defaultTextStyle.merge(_styleSheet.textStyle);

    _tree.add(_TreeElement.fromAstElement(
      element,
      style: builder.buildTextStyle(element, defaultTextStyle),
    ));
    return true;
  }

  @override
  void visitText(MarkdownText text) {
    final parent = _tree.last;
    final builder = _builders[parent.type]!;
    final textContent = _keepLineEndingsWhen == null
        ? text.text.replaceAll('\n', ' ')
        : text.text;
    var textSpan = builder.buildText(textContent, parent);

    if (_gestureRecognizers.isNotEmpty) {
      textSpan = TextSpan(
        text: textSpan.text,
        children: textSpan.children,
        semanticsLabel: textSpan.semanticsLabel,
        style: textSpan.style,
        mouseCursor: SystemMouseCursors.click,
        recognizer: _gestureRecognizers.entries.last.value,
      );
    }

    parent.children.add(createRichText(
      textSpan,
      textAlign: builder.textAlign(parent),
    ));
  }

  @override
  void visitElementAfter(MarkdownElement element) {
    final current = _tree.removeLast();
    final type = current.type;
    final parent = _tree.last;
    final builder = _builders[type]!;

    final textSpan = builder.createText(current, parent.style);
    if (textSpan != null) {
      current.children.add(createRichText(textSpan));
    }

    current.children.replaceRange(
      0,
      current.children.length,
      compressWidgets(current.children),
    );

    final widget = builder.buildWidget(current, parent);
    final isBlock = builder.isBlock(current);
    if (widget != null) {
      // Add spacing between block elements
      _tree.last.children.addIfTrue(
        SizedBox(
          height: _blockSpacing,
          // TODO(Zhiguang): Remove it when this issue is fixed:
          // https://github.com/flutter/flutter/issues/104548
          child: selectable
              ? const Text(' \n', selectionColor: Colors.transparent)
              : null,
        ),
        isBlock && _tree.last.children.isNotEmpty,
      );

      if (widget is InlineWraper) {
        parent.children.addAll(widget.children);
      } else {
        if (!isBlock) {
          _checkInlineWidget(widget);
        }

        parent.children.add(widget);
      }
    }

    if (_keepLineEndingsWhen == type) {
      _keepLineEndingsWhen = null;
    }

    _gestureRecognizers.remove(type);
  }

  /// Creates a [RichText] widget.
  Widget createRichText(
    TextSpan text, {
    TextAlign? textAlign,
    StrutStyle? strutStyle,
  }) {
    return RichText(
      strutStyle: strutStyle,
      text: text,
      textAlign: textAlign ?? _textAlign,
      selectionColor: _selectionColor,
      selectionRegistrar: _selectionRegistrar,
    );
  }

  /// Merges the [RichText] elements of [widgets] while it is possible.
  List<Widget> compressWidgets(List<Widget> widgets) => mergeRichText(
        widgets,
        richTextBuilder: (span, textAlign) => createRichText(
          span,
          textAlign: textAlign,
        ),
      );
}

class _TreeElement extends MarkdownTreeElement {
  _TreeElement.root(List<MarkdownNode> children)
      : super(
          element: MarkdownElement.root(children),
          style: null,
        );

  _TreeElement.fromAstElement(MarkdownElement element, {TextStyle? style})
      : super(
          element: element,
          style: style,
        );
}

void _checkInlineWidget(Widget widget) {
  final allowedInlineWidgets = [
    RichText,
    Text,
    DefaultTextStyle,
  ];

  assert(
    allowedInlineWidgets.contains(widget.runtimeType),
    'It is not allowed to return ${widget.runtimeType} from BuildWidget'
    ' when it is not a block widget. The allowed types:'
    '$allowedInlineWidgets',
  );
}
