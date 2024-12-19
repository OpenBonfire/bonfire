[![Flutter CI](https://github.com/tagnote-app/markdown_viewer/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/tagnote-app/markdown_viewer/actions/workflows/flutter-ci.yml)

## Markdown Viewer

A Markdown viewer widget for Flutter. It renders Markdown string to rich text
output.

<img src="https://raw.githubusercontent.com//tagnote-app/markdown_viewer/master/doc/screenshot.png" alt="example" width="425">

Check the source code of this screenshot [here](https://github.com/tagnote-app/markdown_viewer/blob/master/example/lib/main.dart)

### Usage

```dart
MarkdownViewer(
  'Hello **Markdown**!',
  enableTaskList: true,
  enableSuperscript: false,
  enableSubscript: false,
  enableFootnote: false,
  enableImageSize: false,
  enableKbd: false,
  syntaxExtensions: const [],
  elementBuilders: const [],
);
```

### How to create a syntax extension

```dart
class ExampleSyntax extends MdInlineSyntax {
  ExampleSyntax() : super(RegExp(r'#[^#]+?(?=\s+|$)'));

  @override
  MdInlineObject? parse(MdInlineParser parser, Match match) {
    final markers = [parser.consume()];
    final content = parser.consumeBy(match[0]!.length - 1);

    return MdInlineElement(
      'example',
      markers: markers,
      children: content.map((e) => MdText.fromSpan(e)).toList(),
    );
  }
}

```

### How to create a element builder

```dart
class ExampleBuilder extends MarkdownElementBuilder {
  ExampleBuilder()
      : super(
          textStyle: const TextStyle(
            color: Colors.green,
            decoration: TextDecoration.underline,
          ),
        );

  @override
  bool isBlock(element) => false;

  @override
  List<String> matchTypes = <String>['example'];
}
```
