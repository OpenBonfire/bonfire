import 'dart:typed_data';

import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberAvatar extends ConsumerStatefulWidget {
  final Member member;
  final Guild guild;
  final Channel channel;
  const MemberAvatar(
      {super.key,
      required this.member,
      required this.guild,
      required this.channel});

  @override
  ConsumerState<MemberAvatar> createState() => _AvatarState();
}

class _AvatarState extends ConsumerState<MemberAvatar> {
  late Future<Uint8List?> _avatarFuture;

  @override
  void initState() {
    super.initState();
    _avatarFuture = ref
        .read(messagesProvider(widget.guild, widget.channel).notifier)
        .fetchMemberAvatar(widget.member);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 35,
        height: 35,
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
                    width: 35,
                    height: 35,
                  );
                }
              } else {
                return const SizedBox(
                  width: 35,
                  height: 35,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
