import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/auth/views/credentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

class AccountSwitcher extends ConsumerStatefulWidget {
  const AccountSwitcher({super.key});

  @override
  ConsumerState<AccountSwitcher> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<AccountSwitcher> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const CredentialsScreen(
      storeCredentials: true,
    );
  }
}
