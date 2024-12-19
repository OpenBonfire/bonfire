// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_viewer/markdown_viewer.dart';
import '../example/lib/extension.dart';

void main() {
  testWidgets('extension', ((tester) async {
    const data = '''
Hello **Markdown**!

---
#custom_extension
''';

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MaterialApp(
          home: MarkdownViewer(
            data,
            syntaxExtensions: [ExampleSyntax()],
            elementBuilders: [
              ExampleBuilder(),
            ],
          ),
        ),
      ),
    );

    final finder = find.descendant(
      of: find.byType(MarkdownViewer),
      matching: find.text(
        'custom_extension',
        findRichText: true,
      ),
    );
    expect(finder, findsOneWidget);
  }));
}
