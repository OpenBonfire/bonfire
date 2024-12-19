// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prism/flutter_prism.dart';
import 'package:markdown_viewer/markdown_viewer.dart';

import 'extension.dart';

const markdown = r'''
## Markdown example

Hello **Markdown**!

### Highlights

- [x] ==100%== conform to CommonMark.
- [x] ==100%== conform to GFM.
- [x] Easy to implement syntax **highlighting**, for example `flutter_prism`:
   ```dart
   // Dart language.
   void main() {
     print('Hello, World!');
   }
   ```
- [x] Easy to custom, for example:
  > This is a #custom_extension

---
### Dependencies
| Name | Required|
|--|--:|
|`dart_markdown`|Yes|
|`flutter_prism`|No|

''';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      title: 'MarkdownViewer Demo',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      scrollBehavior: CustomScrollBehavior(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MarkdownViewer Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: MarkdownViewer(
          markdown,
          enableTaskList: true,
          enableSuperscript: false,
          enableSubscript: false,
          enableFootnote: false,
          enableImageSize: false,
          enableKbd: false,
          syntaxExtensions: [ExampleSyntax()],
          highlightBuilder: (text, language, infoString) {
            final prism = Prism(
              mouseCursor: SystemMouseCursors.text,
              style: Theme.of(context).brightness == Brightness.dark
                  ? const PrismStyle.dark()
                  : const PrismStyle(),
            );
            return prism.render(text, language ?? 'plain');
          },
          onTapLink: (href, title) {
            print({href, title});
          },
          elementBuilders: [
            ExampleBuilder(),
          ],
          styleSheet: const MarkdownStyle(
            listItemMarkerTrailingSpace: 12,
            codeSpan: TextStyle(
              fontFamily: 'RobotoMono',
            ),
            codeBlock: TextStyle(
              fontSize: 14,
              letterSpacing: -0.3,
              fontFamily: 'RobotoMono',
            ),
          ),
        ),
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
