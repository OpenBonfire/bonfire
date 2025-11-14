import 'package:firebridge/firebridge.dart';

/// Wraps the [code] in a code block with the specified language, if any.
String codeBlock(String code, [String language = '']) =>
    '```$language\n$code\n```';

/// Wraps the [content] inside `backticks`.
String inlineCode(String content) =>
    content.contains('`') ? '``$content``' : '`$content`';

/// Wraps the [content] inside `*`.
String italic(String content) => '*$content*';

/// Wraps the [content] inside `**`.
String bold(String content) => '**$content**';

/// Wraps the [content] inside `__`.
String underline(String content) => '__${content}__';

/// Wraps the [content] inside `~~`.
String strikethrough(String content) => '~~$content~~';

/// Quotes the [content].
String quote(String content) => '> $content';

/// Quotes the [content] in a quote block.
String quoteBlock(String content) => '>>> $content';

/// Wraps the [url] inside `<>`, used to remove its embed.
String hideEmbed(String url) => '<$url>';

/// Format the [content] and the URL into a hyperlink (aka [Markdown link](https://www.markdownguide.org/basic-syntax/#links)), and optionally, add a [title] that will be displayed on hover.
String hyperlink(String content, String url, [String? title]) =>
    '[$content](<$url>${title != null ? ' "$title"' : ''})';

/// Wraps the [content] inside `||`.
String spoiler(String content) => '||$content||';

/// Formats a user ID into a user mention.
String userMention(Snowflake id) => '<@$id>';

/// Formats a channel ID into a channel mention.
String channelMention(Snowflake id) => '<#$id>';

/// Formats a role ID into a role mention.
String roleMention(Snowflake id) => '<@&$id>';

/// Formats the [date] into a date string timestamp.
String formatDate(DateTime date,
        [TimestampStyle style = TimestampStyle.none]) =>
    '<t:${date.millisecondsSinceEpoch ~/ 1000}${style == TimestampStyle.none ? '' : ':${style.style}'}>';

enum TimestampStyle {
  none(''),
  shortTime('t'),
  longTime('T'),
  shortDate('d'),
  longDate('D'),
  shortDateTime('f'),
  longDateTime('F'),
  relativeTime('R');

  /// The style of the timestamp.
  final String style;

  const TimestampStyle(this.style);

  /// Format [date] using this timestamp style.
  String format(DateTime date) => formatDate(date, this);
}
