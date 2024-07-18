import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/auth/views/credentials.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

class AccountSwitcherModel extends ConsumerStatefulWidget {
  const AccountSwitcherModel({super.key});

  @override
  ConsumerState<AccountSwitcherModel> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<AccountSwitcherModel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // GoRouter.of(context).go("/switcher");
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.foreground),
        width: 100,
        height: 100,
      ),
    );
  }
}

class AccountSwitcherScreen extends StatelessWidget {
  const AccountSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CredentialsScreen(
      storeCredentials: true,
    );
  }
}
