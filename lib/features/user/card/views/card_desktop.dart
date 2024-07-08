import 'dart:typed_data';

import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/features/user/card/repositories/self_user.dart';
import 'package:bonfire/features/user/card/repositories/user_avatar.dart';
import 'package:bonfire/shared/utils/status.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class UserCard extends ConsumerStatefulWidget {
  const UserCard({super.key});

  @override
  ConsumerState<UserCard> createState() => SelfUserCardState();
}

class SelfUserCardState extends ConsumerState<UserCard> {
  @override
  Widget build(BuildContext context) {
    User? user = ref.watch(selfUserProvider).valueOrNull;
    UserStatus? status = ref.watch(userStatusStateProvider);

    Uint8List? avatar;
    String name = "";

    if (user != null) {
      avatar = ref.watch(userAvatarProvider(user)).valueOrNull;
      name = user.globalName ?? user.username;
    }

    return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).custom.colorTheme.messageBarBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        avatar ?? Uint8List(0),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: getStatusColor(
                            context, status ?? UserStatus.offline),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.publicSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Status placeholder :D",
                    style: GoogleFonts.publicSans(
                      color: Theme.of(context)
                          .custom
                          .colorTheme
                          .deselectedChannelText,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
