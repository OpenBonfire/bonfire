import 'package:bonfire/features/authenticator/components/local_account_switcher.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showAccountSwitcherDialog(BuildContext context, GoRouter router) {
  if (shouldUseMobileLayout(context)) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => Material(
          color: Theme.of(context).custom.colorTheme.background,
          child: LocalAccountSwitcherScreen(router),
        ),
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).custom.colorTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: SizedBox(
          width: 400,
          height: 400,
          child: LocalAccountSwitcherScreen(router),
        ),
      ),
    );
  }
}
