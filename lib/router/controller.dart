import 'package:bonfire/features/auth/views/login.dart';
import 'package:bonfire/features/auth/views/mfa.dart';
import 'package:bonfire/features/user/views/messages.dart';
import 'package:bonfire/features/overview/views/home.dart';
import 'package:flutter/material.dart';
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
        GoRoute(path: 'mfa', builder: (context, state) => const MFAPage()),
      ],
    ),
    GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'messages',
            // builder: (context, state) => const UserMessagesView()
            pageBuilder: (context, state) => buildPageWithNoTransition<void>(
              context: context,
              state: state,
              child: const UserMessagesView(),
            ),
          ),
        ]),
  ],
);

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

CustomTransitionPage buildPageWithNoTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        child,
  );
}
