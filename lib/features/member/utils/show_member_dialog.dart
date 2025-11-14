import 'package:bonfire/features/member/components/member_popout.dart';
import 'package:bonfire/shared/components/drawer/mobile_drawer.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showMemberDialog(
    BuildContext context, Snowflake userId, Snowflake guildId) async {
  HapticFeedback.mediumImpact();
  if (shouldUseDesktopLayout(context)) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: const Color.fromARGB(0, 0, 0, 0),
            child: UserPopoutCard(
              userId,
              guildId: guildId,
            ),
          );
        });
  } else {
    // open drawer
    GlobalDrawer.of(context)!.setChild(
      UserPopoutCard(
        userId,
        guildId: guildId,
      ),
    );

    GlobalDrawer.of(context)!.toggleDrawer();
  }
}
