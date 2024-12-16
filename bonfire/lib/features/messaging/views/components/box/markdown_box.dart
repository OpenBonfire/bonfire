import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:bonfire/features/messaging/views/components/box/mention_syntax.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prism/flutter_prism.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageMarkdownBox extends StatefulWidget {
  final Message message;
  const MessageMarkdownBox({super.key, required this.message});

  @override
  State<MessageMarkdownBox> createState() => _MessageMarkdownBoxState();
}

class _MessageMarkdownBoxState extends State<MessageMarkdownBox> {
  late EditorState editorState;

  @override
  void initState() {
    editorState = EditorState(
      document: markdownToDocument(widget.message.content),
    )..editable = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Consumer(builder: (context, ref, child) {
    //   return LayoutBuilder(
    //     builder: (context, constraints) {
    //       print(constraints.maxWidth);
    //       print(constraints.maxHeight);
    //       return SizedBox(
    //         width: constraints.maxWidth,
    //         height: 200,
    //         child: AppFlowyEditor(
    //           editorState: editorState,
    //         ),
    //       );
    //     },
    //   );
    return MarkdownViewer(
      widget.message.content,
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
        paragraph: GoogleFonts.publicSans(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFBDBDBD),
        ),
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
    //});
  }
}
