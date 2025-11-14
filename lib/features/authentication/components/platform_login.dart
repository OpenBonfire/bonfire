import 'package:bonfire/features/authentication/qr/auth_by_qrcode.dart';
import 'package:bonfire/features/authentication/views/captcha.dart';
import 'package:bonfire/features/authentication/views/credentials.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_platform/universal_platform.dart';

class PlatformLoginWidget extends ConsumerWidget {
  const PlatformLoginWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Row(
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
    );
  }
}
