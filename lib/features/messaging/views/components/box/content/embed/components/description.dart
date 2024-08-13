import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prism/flutter_prism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_viewer/markdown_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class DescriptionEmbed extends StatelessWidget {
  final Embed embed;

  const DescriptionEmbed({
    super.key,
    required this.embed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        color: embed.color != null
            ? Color.fromRGBO(
                embed.color!.r,
                embed.color!.g,
                embed.color!.b,
                1,
              )
            : Theme.of(context).custom.colorTheme.blurple,
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).custom.colorTheme.foreground,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (embed.author != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
                      child: Row(
                        children: [
                          if (embed.author!.iconUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    embed.author!.iconUrl!.toString()),
                                radius: 12,
                              ),
                            ),
                          Text(
                            embed.author!.name,
                            style: GoogleFonts.publicSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  if (embed.title != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                      child: Text(
                        embed.title!,
                        style: GoogleFonts.publicSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: embed.color != null
                              ? Color.fromRGBO(
                                  embed.color!.r,
                                  embed.color!.g,
                                  embed.color!.b,
                                  1,
                                )
                              : Theme.of(context).custom.colorTheme.blurple,
                        ),
                      ),
                    ),
                  if (embed.description != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 16, 8),
                      child: EmbedMarkdownBox(embed: embed),
                    ),
                  if (embed.image != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 16, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          embed.image!.url.toString(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (embed.footer != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                      child: Row(
                        children: [
                          if (embed.footer!.iconUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Image.network(
                                embed.footer!.iconUrl!.toString(),
                                width: 20,
                                height: 20,
                              ),
                            ),
                          Text(
                            embed.footer!.text,
                            style: GoogleFonts.publicSans(
                                fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmbedMarkdownBox extends StatelessWidget {
  final Embed embed;

  const EmbedMarkdownBox({
    super.key,
    required this.embed,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownViewer(
      embed.description!,
      enableTaskList: true,
      enableSuperscript: false,
      enableSubscript: false,
      enableFootnote: false,
      enableImageSize: false,
      selectable: false,
      enableKbd: false,
      syntaxExtensions: const [],
      elementBuilders: const [],
      highlightBuilder: (text, language, infoString) {
        final prism = Prism(
          style: Theme.of(context).brightness == Brightness.dark
              ? const PrismStyle.dark()
              : const PrismStyle(),
        );
        try {
          var rendered = prism.render(text, language ?? 'plain');
          return rendered;
        } catch (e) {
          return <TextSpan>[TextSpan(text: text)];
        }
      },
      onTapLink: (href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
        }
      },
      styleSheet: MarkdownStyle(
        paragraph: Theme.of(context).custom.textTheme.bodyText1,
        codeBlock: GoogleFonts.jetBrainsMono(
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: Theme.of(context).custom.colorTheme.foreground,
          borderRadius: BorderRadius.circular(8),
        ),
        codeSpan: GoogleFonts.jetBrainsMono(
          backgroundColor: Theme.of(context).custom.colorTheme.foreground,
          fontSize: 14,
        ),
      ),
    );
  }
}
