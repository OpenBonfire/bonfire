import 'package:bonfire/features/user/card/repositories/user_avatar.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class UserAvatar extends ConsumerStatefulWidget {
  final User user;
  final double? size;
  const UserAvatar({
    super.key,
    required this.user,
    this.size,
  });

  @override
  ConsumerState<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends ConsumerState<UserAvatar> {
  bool _isImageLoaded = false;

  @override
  Widget build(BuildContext context) {
    final avatarAsync = ref.watch(userAvatarProvider(widget.user));

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: avatarAsync.when(
        loading: () => _buildShimmerEffect(),
        error: (error, stackTrace) => _buildFallbackWidget(),
        data: (avatar) {
          if (!_isImageLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _isImageLoaded = true;
              });
            });
          }

          return _buildAvatarWithFadeIn(avatar!);
        },
      ),
    );
  }

  // TODO: makle this actually work
  Widget _buildShimmerEffect() {
    final bonfireTheme = BonfireThemeExtension.of(context);
    return Shimmer.fromColors(
      baseColor: bonfireTheme.foreground,
      highlightColor: Colors.white,
      child: const SizedBox(
        width: 35,
        height: 35,
      ),
    );
  }

  Widget _buildFallbackWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: const Center(
        child: Icon(CupertinoIcons.person_fill, size: 20),
      ),
    );
  }

  Widget _buildAvatarWithFadeIn(Uint8List avatar) {
    return AnimatedOpacity(
      opacity: _isImageLoaded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.memory(
          avatar,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
