import 'dart:convert';
import 'dart:io';

import 'package:dart_markdown/dart_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:markdown_viewer/src/extensions.dart';

void main() {
  // _testDirectory('common_mark');
  _testDirectory('original');
  _testDirectory('gfm');
  _testFile(
    'extensions/subscript_superscript.json',
    enableSubscript: true,
    enableSuperscript: true,
  );
  _testFile(
    'extensions/footnotes.json',
    enableFootnote: true,
  );
}

// TODO(Zhiguang): compare the built result with the html result to verify.

void _testDirectory(String name) {
  final directory = '${_getRoot()}/$name';
  final entries = Directory(directory).listSync(
    recursive: true,
    followLinks: false,
  );

  for (final entry in entries) {
    _testFile(entry.path, isFullPath: true);
  }
}

void _testFile(
  String path, {
  bool enableSuperscript = false,
  bool enableSubscript = false,
  bool enableKbd = false,
  bool enableFootnote = false,
  bool isFullPath = false,
}) {
  final rootPath = _getRoot();
  path = isFullPath ? path : '$rootPath/$path';
  final json = File(path).readAsStringSync();
  final mapList = List<Map<String, dynamic>>.from(jsonDecode(json));
  for (final testCase in mapList) {
    final expected = testCase['expected'];
    final description = testCase['description'];
    final data = testCase['markdown'];

    if (expected.isEmpty) {
      continue;
    }

    final shortPath = path.replaceFirst('$rootPath/', '');

    test('file: $shortPath, $description', () {
      final nodes = Markdown(
        enableHtmlBlock: false,
        enableRawHtml: false,
        enableHighlight: true,
        enableStrikethrough: true,
        enableSuperscript: enableSuperscript,
        enableSubscript: enableSubscript,
        enableKbd: enableKbd,
        enableFootnote: enableFootnote,
      ).parse(data);
      final actual = MarkdownRenderer(
        styleSheet: const MarkdownStyle(),
        onTapLink: (_, __) {},
      ).render(nodes).map((e) => e.toMap()).toList();

      expect(actual, expected);
    });
  }
}

/// Markdown test folder.
String _getRoot() {
  final root = File(Platform.script.path).parent.path;
  return '$root/test';
}
