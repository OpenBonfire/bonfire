import 'package:bonfire/features/member/repositories/user_profile.dart';
import 'package:bonfire/features/user/components/presence_avatar.dart';
import 'package:bonfire/features/user/components/user_avatar.dart';
import 'package:bonfire/features/user/controllers/presence.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UserPopoutCard extends ConsumerStatefulWidget {
  final Snowflake userId;
  const UserPopoutCard(this.userId, {super.key});

  @override
  ConsumerState<UserPopoutCard> createState() => _UserPopoutCardState();
}

class _UserPopoutCardState extends ConsumerState<UserPopoutCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).custom;
    final profile =
        ref.watch(userProfileControllerProvider(widget.userId)).valueOrNull;
    final banner = profile?.user.banner;

    PresenceUpdateEvent? presence =
        ref.watch(presenceControllerProvider(widget.userId));

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
          decoration: BoxDecoration(
            color: theme.colorTheme.foreground,
          ),
          width: 500,
          height: 400,
          child: (profile != null)
              ? Stack(
                  children: [
                    Column(
                      children: [
                        (banner != null)
                            ? Image.network(
                                "${banner.url}?size=480",
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150,
                              )
                            : Container(
                                height: 150,
                                decoration: BoxDecoration(
                                    color: (profile.userProfile.accentColor !=
                                            null)
                                        ? Color(profile
                                                .userProfile.accentColor!)
                                            .withAlpha(255)
                                        : theme.colorTheme.background),
                              ),
                      ],
                    ),
                    Positioned(
                      top: 100,
                      left: 35,
                      // child: Container(
                      //   width: 100,
                      //   height: 100,
                      //   color: Colors.white,
                      // ),

                      child: PresenceAvatar(
                        user: profile.user,
                        size: 100,
                        initialPresence: presence,
                      ),
                    )
                  ],
                )
              : Container()),
    );
  }
}
