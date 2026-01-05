// import 'package:bonfire/features/messaging/components/box/mention_syntax.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:bonfire/shared/utils/style/markdown/stylesheet.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prism/flutter_prism.dart';
import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageMarkdownBox extends StatefulWidget {
  final Message message;
  const MessageMarkdownBox({super.key, required this.message});

  @override
  State<MessageMarkdownBox> createState() => _MessageMarkdownBoxState();
}

class _MessageMarkdownBoxState extends State<MessageMarkdownBox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: MarkdownViewer(
            widget.message.content,
            enableTaskList: true,
            enableSuperscript: false,
            enableSubscript: false,
            enableFootnote: false,
            enableImageSize: false,
            selectable: shouldUseDesktopLayout(context),
            enableKbd: false,
            syntaxExtensions: [
              // DiscordMentionSyntax(),
            ],
            elementBuilders: [
              // DiscordMentionBuilder(),
            ],
            highlightBuilder: (text, language, infoString) {
              final prism = Prism(
                style: Theme.of(context).brightness == Brightness.dark
                    ? const PrismStyle.dark()
                    : const PrismStyle(),
              );
              try {
                final rendered = prism.render(text, language ?? 'plain');
                return rendered;
              } catch (e) {
                debugPrint('MessageMarkdownBox: Error in highlightBuilder: $e');
                return <TextSpan>[TextSpan(text: text)];
              }
            },
            onTapLink: (href, title) {
              launchUrl(Uri.parse(href!), mode: LaunchMode.externalApplication);
            },
            styleSheet: getMarkdownStyleSheet(context),
          ),
        ),
      ],
    );
  }
}
