import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/auth/views/credentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    String? token = GetStorage().read('token');
    if (token != null) {
      print("reading token...");
      ref.read(authProvider.notifier).loginWithToken(token);
    } else {
      print("no token found");
    }
  }

  @override
  Widget build(BuildContext context) {
    var auth = ref.watch(authProvider);

    if (auth is MFARequired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/mfa');
      });
    } else if (auth is AuthUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/overview/home');
      });
    }

    return const CredentialsScreen();
  }
}
