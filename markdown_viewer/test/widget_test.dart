import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_viewer/markdown_viewer.dart';

void main() {
  testWidgets('when empty', ((tester) async {
    await tester.pumpWidget(_createWidget(''));

    final childWidgets = _descendant();
    expect(childWidgets.elementAt(0).runtimeType, SelectionArea);
    expect(childWidgets.last.toString(), const SizedBox.shrink().toString());
  }));

  testWidgets('when has only one block child', ((tester) async {
    await tester.pumpWidget(_createWidget('Foo'));

    final childWidgets = _descendant();
    final lastIndex = childWidgets.length - 1;

    // This column is from MarkdownBuilder.
    expect(childWidgets.elementAt(lastIndex - 1).runtimeType, Column);
    expect(childWidgets.elementAt(lastIndex).runtimeType, RichText);
  }));

  testWidgets('when has multiple block child', ((tester) async {
    await tester.pumpWidget(_createWidget('bar\n# Foo'));

    final childWidgets = _descendant();
    final lastIndex = childWidgets.length - 1;

    expect(childWidgets.elementAt(lastIndex - 2).runtimeType, Padding);
    expect(childWidgets.elementAt(lastIndex - 1).runtimeType, Column);
  }));

  testWidgets('when not selectable', ((tester) async {
    await tester.pumpWidget(_createWidget('Foo', selectable: false));
    final childWidgets = _descendant();
    expect(childWidgets.first.runtimeType, Column);
  }));
}

Widget _createWidget(
  String markdown, {
  bool selectable = true,
}) =>
    MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: MarkdownViewer(
          markdown,
          selectable: selectable,
        ),
      ),
    );

Iterable<Widget> _descendant() => collectAllElementsFrom(
      find.byType(MarkdownViewer).evaluate().single,
      skipOffstage: false,
    ).map((e) => e.widget);
