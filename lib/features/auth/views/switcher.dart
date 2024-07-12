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
    // var auth = ref.watch(authProvider);

    // if (auth is MFARequired) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     context.go('/mfa');
    //   });
    // } else if (auth is AuthUser) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) async {
    //     // yep, I did this.
    //     var lastLocation = Hive.box("last-location");
    //     String? guildId = lastLocation.get("guildId");
    //     String? channelId = lastLocation.get("channelId");

    //     context.go('/channels/${guildId ?? 0}/${channelId ?? 0}');
    //   });
    // }

    return const CredentialsScreen(
      storeCredentials: true,
    );
  }
}
