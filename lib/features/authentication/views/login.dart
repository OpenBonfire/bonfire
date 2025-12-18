import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:bonfire/features/authentication/components/platform_login.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    var auth = await Hive.openBox('auth');
    var token = auth.get('token');

    if (token != null) {
      // var client = ref.watch(clientControllerProvider);
      if (client is AuthUser) {
        return;
      }
      final newClient = await ref
          .read(clientControllerProvider.notifier)
          .loginWithToken(token);
      _navigateToLastLocation();
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Loading Bonfire...",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).textTheme.bodyMedium!.color!,
              ),
            ),
            const SizedBox(height: 30),
            LoadingAnimationWidget.fourRotatingDots(
              color: Theme.of(context).textTheme.bodyMedium!.color!,
              size: 50,
            ),
          ],
        ),
      );
    }

    return const Center(child: PlatformLoginWidget());
  }

  void _navigateToLastLocation() {
    var lastLocation = Hive.box("last-location");
    String? guildId = lastLocation.get("guildId");
    String? channelId = lastLocation.get("channelId");
    context.go('/channels/${guildId ?? '0'}/${channelId ?? '0'}');
  }
}
