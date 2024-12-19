import 'package:flutter/material.dart';

import '../ast.dart';
import '../definition.dart';
import 'builder.dart';

/// A builder to create list.
class ListBuilder extends MarkdownElementBuilder {
  ListBuilder({
    TextStyle? list,
    TextStyle? listItem,
    this.listItemMarker,
    this.listItemMarkerTrailingSpace,
    required this.listItemMinIndent,
    this.checkbox,
    this.listItemMarkerBuilder,
    this.checkboxBuilder,
    this.paragraphPadding,
  }) : super(textStyleMap: {
          'orderedList': list,
          'bulletList': list,
          'listItem': listItem,
        });

  final TextStyle? listItemMarker;
  final TextStyle? checkbox;
  final double? listItemMarkerTrailingSpace;
  final double? listItemMinIndent;
  final MarkdownListItemMarkerBuilder? listItemMarkerBuilder;
  final MarkdownCheckboxBuilder? checkboxBuilder;
  final EdgeInsets? paragraphPadding;

  @override
  final matchTypes = ['orderedList', 'bulletList', 'listItem'];

  final _listStrack = <MarkdownElement>[];

  bool _isList(String type) => type == 'orderedList' || type == 'bulletList';

  @override
  void init(element) {
    final type = element.type;
    if (_isList(type)) {
      _listStrack.add(element);
    }
  }

  @override
  Widget? buildWidget(element, parent) {
    final type = element.type;
    final child = super.buildWidget(element, parent);
    if (_isList(type)) {
      _listStrack.removeLast();
      return child;
    }

    final itemMarker = element.attributes['taskListItem'] == null
        ? _buildListItemMarker(
            _listStrack.last.type,
            element.attributes['number'],
            element.style,
          )
        : _buildCheckbox(
            element.attributes['taskListItem'] == 'checked',
            element.style,
          );

    final markerContainerHeight = _getLineHeight(element.style);

    final listItem = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: markerContainerHeight ?? 0.0,
            maxHeight: markerContainerHeight ?? double.infinity,
            minWidth: listItemMinIndent ?? 30.0,
          ),
          child: Align(
            child: Padding(
              padding: EdgeInsets.only(
                right: listItemMarkerTrailingSpace ?? 12.0,
              ),
              child: itemMarker,
            ),
          ),
        ),
        if (child != null) Expanded(child: child),
      ],
    );

    final hasParagraphPadding =
        paragraphPadding != null && paragraphPadding != EdgeInsets.zero;

    if (_listStrack.last.attributes['isTight'] == 'true' ||
        !hasParagraphPadding) {
      return listItem;
    }

    return Padding(
      padding: paragraphPadding!,
      child: listItem,
    );
  }

  Widget _buildListItemMarker(
    String type,
    String? number,
    TextStyle? listItemStyle,
  ) {
    final listType = type == 'bulletList'
        ? MarkdownListType.unordered
        : MarkdownListType.ordered;

    if (listItemMarkerBuilder != null) {
      return listItemMarkerBuilder!(listType, number);
    }

    // Return a `RichText` to make the makers unselectable.
    return RichText(
      text: TextSpan(
        text: listType == MarkdownListType.unordered ? '\u2022' : '$number.',
        style: TextStyle(
          color: listItemStyle?.color?.withOpacity(0.75) ?? Colors.black,
          fontSize: listType == MarkdownListType.unordered
              ? (listItemStyle?.fontSize ?? 16) * 1.4
              : (listItemStyle?.fontSize ?? 16) * 0.96,
        ).merge(listItemMarker),
      ),
      strutStyle: StrutStyle(
        height: listItemStyle?.height,
        forceStrutHeight: true,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildCheckbox(bool checked, TextStyle? listItemStyle) {
    if (checkboxBuilder != null) {
      return checkboxBuilder!(checked);
    }

    final checkboxStyle = TextStyle(
      fontSize: (listItemStyle?.fontSize ?? 16.0) * 1.2,
    ).merge(checkbox);

    return Icon(
      checked ? Icons.check_box_outlined : Icons.check_box_outline_blank,
      size: checkboxStyle.fontSize,
      color: checkboxStyle.color,
    );
  }

  double? _getLineHeight(TextStyle? style) {
    if (style == null || style.fontSize == null) {
      return null;
    }

    return style.fontSize! * (style.height ?? 1);
  }
}
