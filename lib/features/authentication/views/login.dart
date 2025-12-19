import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:bonfire/features/authentication/components/platform_login.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  FirebridgeGateway? client;
  // final fireviewController = FireviewController();
  bool? authMissing;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthToken();
    });
  }

  void _checkAuthToken() async {
    final auth = await Hive.openBox('auth');
    final token = auth.get('token');

    if (token != null) {
      if (client is AuthUser) {
        return;
      }
      await ref.read(clientControllerProvider.notifier).loginWithToken(token);
    } else {
      setState(() {
        authMissing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (authMissing == null) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: .circular(36),
          ),
          width: 500,
          height: 400,
        ),
      );
    }

    return const Center(child: PlatformLoginWidget());
  }
}
