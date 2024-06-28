import 'dart:typed_data';

import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Avatar extends ConsumerWidget {
  final double? width;
  final double? height;
  final MessageAuthor author;
  final Guild guild;
  final Channel channel;
  const Avatar(
      {super.key,
      required this.author,
      required this.guild,
      required this.channel,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: This kinda sucks. We should do something else for icons (maybe).
    var avatarFuture = ref
        .read(messagesProvider(guild, channel).notifier)
        .fetchMessageAuthorAvatar(author);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: width ?? 45,
        height: height ?? 45,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: FutureBuilder<Uint8List?>(
            future: avatarFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Image.memory(snapshot.data!);
                } else {
                  return SizedBox(
                    width: width ?? 45,
                    height: height ?? 45,
                  );
                }
              } else {
                return SizedBox(
                  width: width ?? 45,
                  height: height ?? 45,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
