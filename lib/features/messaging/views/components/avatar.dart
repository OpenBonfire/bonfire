import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Avatar extends ConsumerStatefulWidget {
  final MessageAuthor author;
  const Avatar({super.key, required this.author});

  @override
  ConsumerState<Avatar> createState() => _AvatarState();
}

class _AvatarState extends ConsumerState<Avatar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: SizedBox(
            width: 45,
            height: 45,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: FutureBuilder(
                    future: ref
                        .read(messagesProvider.notifier)
                        .fetchMemberAvatar(widget.author),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Image.memory(snapshot.data!);
                      } else {
                        return const SizedBox(
                          width: 45,
                          height: 45,
                        );
                      }
                    }))));
  }
}
