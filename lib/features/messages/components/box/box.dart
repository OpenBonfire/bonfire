import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/media/components/image.dart';
import 'package:bonfire/features/messages/components/box/render/markdown.dart';
import 'package:bonfire/shared/utils/time.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBox extends ConsumerWidget {
  final Message message;
  final bool showAuthor;
  const MessageBox({
    super.key,
    required this.message,
    required this.showAuthor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final client = ref.watch(clientControllerProvider);
    final author = message.author;
    final avatar = author.avatar;

    // TODO: Role color
    final textColor = theme.colorScheme.onSurface;

    return Row(
      crossAxisAlignment: .start,
      children: [
        if (showAuthor)
          SizedBox(
            width: 42,
            height: 42,
            child: DiscordNetworkImage(
              avatar.getUrl(client!).toString(),
              fit: .cover,
              borderRadius: .circular(100),
            ),
          )
        else
          SizedBox(width: 42),
        SizedBox(width: 8),
        Flexible(
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            children: [
              if (showAuthor)
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: author.displayName,
                        style: GoogleFonts.publicSans(
                          letterSpacing: 0.3,
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(
                        text: dateTimeFormat(message.timestamp.toLocal()),
                        style: GoogleFonts.publicSans(
                          letterSpacing: 0.3,
                          color: const Color.fromARGB(189, 255, 255, 255),
                          fontSize: 11,
                        ),
                      ),
                      if (message.editedTimestamp != null)
                        TextSpan(
                          text: " (edited)",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                    ],
                  ),
                ),
              MessageMarkdownBox(message: message),
            ],
          ),
        ),
      ],
    );
  }
}
