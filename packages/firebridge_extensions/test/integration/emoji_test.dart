import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:test/test.dart';

void main() {
  test('getEmojiDefinitions', () async {
    final emojis = await getEmojiDefinitions();

    expect(emojis, isNotEmpty);
  });

  test('getEmojiDefinitions correcly decodes emojis', () async {
    final emoji = (await getEmojiDefinitions()).singleWhere((element) => element.primaryName == 'heart');

    expect(emoji.surrogates, equals('❤️'));
  });
}
