import 'package:bonfire/features/messaging/views/components/box/mention_syntax.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prism/flutter_prism.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageMarkdownBox extends StatelessWidget {
  final Message message;
  const MessageMarkdownBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return MarkdownViewer(
        message.content,
        enableTaskList: true,
        enableSuperscript: false,
        enableSubscript: false,
        enableFootnote: false,
        enableImageSize: false,
        selectable: false,
        enableKbd: false,
        syntaxExtensions: const [
          // DiscordMentionSyntax(),
        ],
        elementBuilders: [
          DiscordMentionBuilder(),
        ],
        highlightBuilder: (text, language, infoString) {
          final prism = Prism(
              style: Theme.of(context).brightness == Brightness.dark
                  ? const PrismStyle.dark()
                  : const PrismStyle());
          try {
            var rendered = prism.render(text, language ?? 'plain');
            return rendered;
          } catch (e) {
            print('MessageMarkdownBox: Error in highlightBuilder: $e');
            return <TextSpan>[TextSpan(text: text)];
          }
        },
        onTapLink: (href, title) {
          launchUrl(Uri.parse(href!), mode: LaunchMode.externalApplication);
        },
        styleSheet: MarkdownStyle(
          paragraph: Theme.of(context).custom.textTheme.bodyText1,
          codeBlock: GoogleFonts.jetBrainsMono(
            fontSize: 14,
          ),
          codeblockDecoration: BoxDecoration(
              color: Theme.of(context).custom.colorTheme.foreground,
              borderRadius: BorderRadius.circular(8)),
          codeSpan: GoogleFonts.jetBrainsMono(
            backgroundColor: Theme.of(context).custom.colorTheme.foreground,
            fontSize: 14,
          ),
        ),
      );
    });
  }
}
