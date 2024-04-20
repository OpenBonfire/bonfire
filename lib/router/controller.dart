import 'package:bonfire/features/auth/views/login.dart';
import 'package:bonfire/features/auth/views/mfa.dart';
import 'package:bonfire/features/overview/views/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

final routerController = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: 'register',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
            path: 'mfa',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                  child: const MFAPage());
            }),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    )
  ],
);
