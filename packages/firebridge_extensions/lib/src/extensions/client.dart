import 'package:firebridge/firebridge.dart';
import 'package:firebridge_extensions/src/utils/emoji.dart';

/// Extensions on [NyxxRest].
extension NyxxRestExtensions on NyxxRest {
  /// List all the text emoji available to this client.
  Future<List<TextEmoji>> getTextEmojis() async => (await getEmojiDefinitions())
      .map((definition) => TextEmoji(
          id: Snowflake.zero,
          manager: guilds[Snowflake.zero].emojis,
          name: definition.surrogates))
      .toList();

  /// Get a text emoji by name.
  TextEmoji getTextEmoji(String name) => TextEmoji(
      id: Snowflake.zero, manager: guilds[Snowflake.zero].emojis, name: name);
}
