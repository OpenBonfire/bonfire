import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/auth/views/captcha.dart';
import 'package:bonfire/features/auth/views/credentials.dart';
import 'package:fireview/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:universal_platform/universal_platform.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final fireviewController = FireviewController();
  @override
  void initState() {
    super.initState();
    _checkAuthToken();
  }

  void _checkAuthToken() async {
    var auth = await Hive.openBox('auth');
    var token = auth.get('token');

    if (token != null) {
      ref.read(authProvider.notifier).loginWithToken(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    var auth = ref.watch(authProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth is MFARequired) {
        context.go('/mfa');
      } else if (auth is AuthUser) {
        _navigateToLastLocation();
      }
    });

    if (UniversalPlatform.isWeb) {
      return const CaptchaView();
    }
    return CredentialsScreen(fireviewController: fireviewController);
  }

  void _navigateToLastLocation() async {
    var lastLocation = await Hive.openBox("last-location");
    String? guildId = lastLocation.get("guildId");
    String? channelId = lastLocation.get("channelId");
    context.pushReplacement('/channels/${guildId ?? '0'}/${channelId ?? '0'}');
  }
}
