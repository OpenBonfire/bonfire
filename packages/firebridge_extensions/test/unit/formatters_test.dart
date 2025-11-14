import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:test/test.dart';

const testContent = 'This is a `test` content';

void main() {
  group('Format Content', () {
    test(
      'Code Block',
      () => expect(
        codeBlock(testContent, 'dart'),
        equals(
          '''
```dart
$testContent
```''',
        ),
      ),
    );

    test(
      'Inline Code',
      () => expect(
        inlineCode(testContent),
        equals('``$testContent``'),
      ),
    );

    test(
      'Italic',
      () => expect(
        italic(testContent),
        equals('*$testContent*'),
      ),
    );

    test(
      'Bold',
      () => expect(
        bold(testContent),
        equals('**$testContent**'),
      ),
    );

    test(
      'Underline',
      () => expect(
        underline(testContent),
        equals('__${testContent}__'),
      ),
    );

    test(
      'Strikethrough',
      () => expect(
        strikethrough(testContent),
        equals('~~$testContent~~'),
      ),
    );

    test(
      'Quote',
      () => expect(
        quote(testContent),
        equals('> $testContent'),
      ),
    );

    test(
      'Quote Block',
      () => expect(
        quoteBlock(testContent),
        equals('>>> $testContent'),
      ),
    );

    test(
      'Hide Embed',
      () => expect(
        hideEmbed(testContent),
        equals('<$testContent>'),
      ),
    );

    test(
      'Hyperlink',
      () => expect(
        hyperlink(testContent, 'https://example.com', 'Example'),
        equals('[$testContent](<https://example.com> "Example")'),
      ),
    );

    test(
      'Spoiler',
      () => expect(
        spoiler(testContent),
        equals('||$testContent||'),
      ),
    );
  });
}
