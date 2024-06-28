import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bonfire/features/auth/views/login.dart';
import 'package:bonfire/features/auth/views/mfa.dart';
import 'package:bonfire/features/overview/views/navigation_frame.dart';
import 'package:bonfire/features/overview/views/home.dart';

final routerController = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
      routes: [
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
          builder: (context, state) => const MFAPage(),
        ),
        ShellRoute(
          builder: (context, state, child) => NavigationFrame(child: child),
          routes: [
            GoRoute(
              path: 'channels',
              redirect: (context, state) => 'channels/@me',
            ),
            GoRoute(
              path: 'channels/@me/:channelId',
              builder: (context, state) {
                // return messages (todo)
                return const Placeholder();
              },
            ),
            GoRoute(
              path: 'channels/:guildId/:channelId',
              builder: (context, state) {
                final guildId = state.pathParameters['guildId'] ?? '@me';
                final channelId = state.pathParameters['channelId']!;
                return GuildMessagingOverview(
                  guildId: guildId,
                  channelId: channelId,
                );
              },
            ),
          ],
        ),
      ],
    ),
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
