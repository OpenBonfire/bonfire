import 'package:bonfire/shared/utils/style/markdown/stylesheet.dart';
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
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).custom.colorTheme.foreground,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
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
            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (embed.author != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
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
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Text(
                        embed.title!,
                        style: GoogleFonts.publicSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (embed.description != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                      child: EmbedMarkdownBox(embed: embed),
                    ),
                  if (embed.image != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image(
                            image: NetworkImage(
                              embed.image!.proxiedUrl!.toString(),
                              webHtmlElementStrategy:
                                  WebHtmlElementStrategy.prefer,
                            ),
                            fit: BoxFit.cover,
                          )),
                    ),
                  if (embed.footer != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFBDBDBD),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
      selectable: true,
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
      styleSheet: getMarkdownStyleSheet(context),
    );
  }
}
