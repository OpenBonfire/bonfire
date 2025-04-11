import 'package:bonfire/features/authenticator/components/local_account_switcher.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showAccountSwitcherDialog(BuildContext context, GoRouter router) {
  showDialog(
      context: context,
      builder: (context) {
        if (shouldUseMobileLayout(context)) {
          return Dialog.fullscreen(
              backgroundColor: Theme.of(context).custom.colorTheme.background,
              child: LocalAccountSwitcherScreen(router));
        }
        return Dialog(
            backgroundColor: Theme.of(context).custom.colorTheme.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: LocalAccountSwitcherScreen(router));
      });
}
