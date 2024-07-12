import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/auth/views/credentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    var auth = Hive.openBox('auth');

    auth.then((value) {
      var token = value.get('token');
      if (token != null) {
        ref.read(authProvider.notifier).loginWithToken(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var auth = ref.watch(authProvider);

    if (auth is MFARequired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/mfa');
      });
    } else if (auth is AuthUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        var lastLocation = Hive.box("last-location");
        String? guildId = lastLocation.get("guildId");
        String? channelId = lastLocation.get("channelId");

        context.go('/channels/${guildId ?? 0}/${channelId ?? 0}');
      });
    }

    return const CredentialsScreen(
      storeCredentials: false,
    );
  }
}
