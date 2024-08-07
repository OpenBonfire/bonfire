import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/auth/views/captcha.dart';
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

    return Stack(
      children: [
        const CredentialsScreen(
          storeCredentials: false,
        ),
        if (auth is CaptchaResponse)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CaptchaView(
                  captchaKey: auth.captcha_key,
                  captchaService: auth.captcha_service,
                  captchaSitekey: auth.captcha_sitekey,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _navigateToLastLocation() async {
    var lastLocation = await Hive.openBox("last-location");
    String? guildId = lastLocation.get("guildId");
    String? channelId = lastLocation.get("channelId");
    context.go('/channels/${guildId ?? '0'}/${channelId ?? '0'}');
  }
}
