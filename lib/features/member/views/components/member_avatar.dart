import 'package:bonfire/features/messaging/repositories/avatar.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var avatar = ref.watch(memberAvatarProvider(widget.member)).valueOrNull;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
          width: 35,
          height: 35,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child:
                  (avatar != null) ? Image.memory(avatar) : const SizedBox())),
    );
  }
}
