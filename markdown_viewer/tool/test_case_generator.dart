import 'dart:convert';
import 'dart:io';
import 'package:dart_markdown/dart_markdown.dart' as md;
import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:markdown_viewer/src/extensions.dart';

void main() {
  // generateTestCases('common_mark');
  generateTestCases('gfm');
}

void generateTestCases(String flavorName) {
  final fileName = {
    'common_mark': 'tool/assets/common_mark_tests.json',
    'gfm': 'tool/assets/gfm_tests.json'
  }[flavorName];

  final url = {
    'common_mark': 'https://spec.commonmark.org/0.30',
    'gfm': 'https://github.github.com/gfm'
  }[flavorName];

  final root = File(Platform.script.path).parent.path;
  final file = File('$root/$fileName');
  final json = file.readAsStringSync();
  final list = List<Map<String, dynamic>>.from(jsonDecode(json));

  final testCases = <String, List<Map<String, dynamic>>>{};
  for (final item in list) {
    final sectionName = item['section'] as String;
    final markdown = item['markdown'] as String;
    testCases[sectionName] ??= <Map<String, dynamic>>[];
    testCases[sectionName]!.add({
      'description': '$sectionName, $url/#example-${item['example']}',
      'markdown': markdown,
      "expected": _renderTestCase(markdown),
    });
  }

  for (final entry in testCases.entries) {
    final fineName = _fileNameFromSection(entry.key);
    final outputPath = '$root/test/$flavorName/$fineName';
    final testCases = const JsonEncoder.withIndent("  ").convert(entry.value);
    File(outputPath).writeAsStringSync('$testCases\n');
  }
}

String _fileNameFromSection(String section) =>
    '${section.toLowerCase().replaceAll(RegExp(r'[ \)\(]+'), '_')}.json';

/// Renders Markdown String to expected data.
List<Map<String, dynamic>> _renderTestCase(String markdown) {
  final nodes = md.Markdown(
    enableHtmlBlock: false,
    enableRawHtml: false,
    enableHighlight: true,
    enableStrikethrough: true,
  ).parse(markdown);

  return MarkdownRenderer(
    styleSheet: const MarkdownStyle(),
    onTapLink: (_, __) {},
  ).render(nodes).map((e) => e.toMap()).toList();
}
