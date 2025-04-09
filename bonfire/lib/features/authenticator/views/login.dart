import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/features/authenticator/qr/auth_by_qrcode.dart';
import 'package:bonfire/features/authenticator/views/captcha.dart';
import 'package:bonfire/features/authenticator/views/credentials.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:bonfire/theme/theme.dart';
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
  // final fireviewController = FireviewController();
  bool? authMissing;
  @override
  void initState() {
    super.initState();
    ref.listenManual(authProvider, (a, b) {
      if (b is AuthUser) {
        b.client.onReady.listen((_) {
          print("User is Ready!");
          _navigateToLastLocation();
        });
      }
    });

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

    final theme = Theme.of(context);

    return Scaffold(
        body: Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isSmartwatch(context) && UniversalPlatform.isMobile)
            const Expanded(child: WebviewLoginScreen()),
          if (!UniversalPlatform.isMobile || UniversalPlatform.isWeb)
            const TokenLoginWidget(),
          if (!isSmartwatch(context) && !shouldUseMobileLayout(context))
            const SizedBox(width: 30),
          if (isSmartwatch(context))
            const Expanded(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: AuthByQRcode(),
            )),
          if (!shouldUseMobileLayout(context) && !isSmartwatch(context))
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 250,
                  height: 250,
                  child: AuthByQRcode(),
                ),
                // if (!isSmartwatch(context))
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Text("Login with QR-code",
                        style: theme.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white)),
                    const SizedBox(height: 10),
                    SizedBox(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Scan code with your ',
                          style: theme.textTheme.bodyMedium,
                          children: const <TextSpan>[
                            TextSpan(
                                text: 'Discord mobile app',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' to login in.'),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
        ],
      ),
    ));
  }

  void _navigateToLastLocation() {
    var lastLocation = Hive.box("last-location");
    String? guildId = lastLocation.get("guildId");
    String? channelId = lastLocation.get("channelId");
    context.go('/channels/${guildId ?? '0'}/${channelId ?? '0'}');
  }
}
