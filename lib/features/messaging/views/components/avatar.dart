import 'dart:typed_data';

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
  late Future<Uint8List?> _avatarFuture;

  @override
  void initState() {
    super.initState();
    _avatarFuture = ref
        .read(messagesProvider.notifier)
        .fetchMemberAvatar(widget.author);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 45,
        height: 45,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: FutureBuilder<Uint8List?>(
            future: _avatarFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Image.memory(snapshot.data!);
                } else {
                  return const SizedBox(
                    width: 45,
                    height: 45,
                );
                }
              } else {
                return const SizedBox(
                  width: 45,
                  height: 45,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
