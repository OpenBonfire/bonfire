import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/media/components/image.dart';
import 'package:bonfire/features/messages/components/box/render/markdown.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageBox extends ConsumerWidget {
  final Message message;
  const MessageBox({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final client = ref.watch(clientControllerProvider);
    final author = message.author;
    final avatar = author.avatar;

    // print(avatar.getUrl(client!).toString());
    print("hash = ${author.avatarHash}");

    return Row(
      children: [
        SizedBox(
          width: 45,
          height: 45,
          child: DiscordNetworkImage(
            avatar.getUrl(client!).toString(),
            fit: .cover,
            borderRadius: .circular(100),
          ),
        ),
        SizedBox(width: 4),
        Flexible(
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            children: [
              Text(
                author.displayName,
                style: theme.textTheme.bodyMedium!.copyWith(fontWeight: .bold),
              ),
              MessageMarkdownBox(message: message),
            ],
          ),
        ),
      ],
    );
  }
}
