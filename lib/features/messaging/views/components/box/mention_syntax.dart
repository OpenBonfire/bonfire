import 'package:flutter/material.dart';
import 'package:markdown_viewer/markdown_viewer.dart';

class DiscordMentionSyntax extends MdInlineSyntax {
  DiscordMentionSyntax() : super(RegExp(r'<(@!?|@&|#)(\d{17,19})>'));

  @override
  MdInlineObject? parse(MdInlineParser parser, Match match) {
    final markers = [parser.consume()];
    final content = parser.consumeBy(match[0]!.length - 1);
    final children = content.map((e) => MdText.fromSpan(e)).toList();

    return MdInlineElement(
      'discord_mention',
      markers: markers,
      children: children,
      start: markers.first.start,
      end: children.last.end,
      attributes: {'type': match[1]!, 'id': match[2]!},
    );
  }
}

class DiscordMentionBuilder extends MarkdownElementBuilder {
  DiscordMentionBuilder()
      : super(
          textStyle: TextStyle(
            color: const Color(0xFF5865F2),
            fontWeight: FontWeight.bold,
            backgroundColor: const Color(0xFF5865F2).withOpacity(0.3),
          ),
        );

  @override
  bool isBlock(element) => false;

  @override
  List<String> get matchTypes => ['discord_mention'];

  @override
  Widget? buildWidget(MarkdownTreeElement element, MarkdownTreeElement parent) {
    final type = element.attributes['type'];
    final id = element.attributes['id'];
    final mentionText = _getMentionText(type!, id!);

    return Text(
      mentionText,
      style: textStyle,
    );
  }

  String _getMentionText(String type, String id) {
    switch (type) {
      case '@':
      case '@!':
        return '@User Not Implemented';
      case '@&':
        return '@Role Not Implemented';
      case '#':
        return '#channel';
      default:
        return '@Unknown';
    }
  }
}
