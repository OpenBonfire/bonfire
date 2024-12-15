import 'package:bonfire/features/user/card/repositories/user_avatar.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAvatar extends ConsumerStatefulWidget {
  final User user;
  const UserAvatar({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<UserAvatar> createState() => _AvatarState();
}

class _AvatarState extends ConsumerState<UserAvatar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var avatar = ref.watch(userAvatarProvider(widget.user)).valueOrNull;
    return SizedBox(
      width: 35,
      height: 35,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: (avatar != null) ? Image.memory(avatar) : const SizedBox()),
    );
  }
}
