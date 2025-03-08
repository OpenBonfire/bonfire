import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/auth/views/captcha.dart';
import 'package:bonfire/features/auth/views/credentials.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:fireview/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final fireviewController = FireviewController();
  bool? authMissing;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthToken();
    });
  }

  void _checkAuthToken() async {
    var auth = await Hive.openBox('auth');
    var token = auth.get('token');

    if (token != null) {
      var client = ref.read(authProvider.notifier).getAuth();
      if (client is AuthUser) {
        return;
      }
      ref.read(authProvider.notifier).loginWithToken(token);
    } else {
      setState(() {
        authMissing = true;
      });
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
    if (authMissing == null) {
      // TODO: Make sick bonfire loading screen
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Loading Bonfire...",
                  style: Theme.of(context)
                      .custom
                      .textTheme
                      .titleMedium
                      .copyWith(
                        color:
                            Theme.of(context).custom.textTheme.bodyText1.color!,
                      )),
              const SizedBox(height: 30),
              LoadingAnimationWidget.fourRotatingDots(
                color: Theme.of(context).custom.textTheme.bodyText1.color!,
                size: 50,
              ),
            ],
          ),
        ),
      );
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
