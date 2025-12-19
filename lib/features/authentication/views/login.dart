import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:bonfire/features/authentication/components/platform_login.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  FirebridgeGateway? client;
  bool? authMissing;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthToken();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAuthToken() async {
    final auth = await Hive.openBox('auth');
    final token = auth.get('token');

    if (token != null) {
      if (client is AuthUser) {
        return;
      }
      await ref.read(clientControllerProvider.notifier).loginWithToken(token);
      context.go("/channels/@me");
    } else {
      setState(() {
        authMissing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(36);
    if (authMissing == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final glowIntensity = (0.3 + (_animationController.value * 0.2));
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: glowIntensity),
                    theme.colorScheme.primary.withValues(
                      alpha: glowIntensity * 0.6,
                    ),
                    theme.colorScheme.primary.withValues(
                      alpha: glowIntensity * 0.3,
                    ),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  width: 500,
                  height: 400,
                  child: ClipRRect(
                    borderRadius: radius,
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: .min,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.orange.shade300,
                                    Colors.orange.shade600,
                                    Colors.deepOrange.shade700,
                                    Colors.orange.shade400,
                                  ],
                                  stops: [
                                    0.0,
                                    _animationController.value * 0.5,
                                    _animationController.value,
                                    1.0,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Bonfire',
                                  style: theme.textTheme.headlineLarge,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "We're getting you loaded in",
                                style: theme.textTheme.labelLarge!.copyWith(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  fontWeight: .w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          bottom: 0,
                          child: Align(
                            alignment: .bottomCenter,
                            child: SizedBox(
                              height: 15,
                              child: LinearProgressIndicator(
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerLow,
                                borderRadius: .circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return const Center(child: PlatformLoginWidget());
  }
}
