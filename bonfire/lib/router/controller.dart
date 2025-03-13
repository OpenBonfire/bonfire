import 'package:bonfire/features/auth/views/switcher.dart';
import 'package:bonfire/features/me/views/messages.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bonfire/features/auth/views/login.dart';
import 'package:bonfire/features/auth/views/mfa.dart';
import 'package:bonfire/features/overview/views/navigation_frame.dart';
import 'package:bonfire/features/overview/views/home.dart';
import 'package:hive_ce/hive.dart';

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
          path: 'switcher',
          builder: (context, state) => const AccountSwitcherScreen(),
        ),
        GoRoute(
          path: 'switcher/model',
          builder: (context, state) => const AccountSwitcherModel(),
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
                path: 'overview/notifications',
                builder: (context, state) => Scaffold(
                      body: Center(
                        child: Text(
                          'Coming Soon',
                          style: Theme.of(context).custom.textTheme.titleMedium,
                        ),
                      ),
                    )),
            GoRoute(
              path: 'channels',
              redirect: (context, state) => 'channels/@me',
            ),
            GoRoute(
              path: 'channels/@me',
              pageBuilder: (context, state) {
                return buildPageWithNoTransition(
                  context: context,
                  state: state,
                  child: GuildMessagingOverview(
                    guildId: Snowflake.zero,
                    channelId: Snowflake.zero,
                  ),
                );
              },
            ),
            GoRoute(
              path: 'channels/:guildId/:channelId',
              pageBuilder: (context, state) {
                String guildId = state.pathParameters['guildId'] ?? '@me';
                if (guildId == '@me') guildId = "0";

                final channelId = state.pathParameters['channelId']!;
                var lastLocation = Hive.box("last-location");
                lastLocation.put("guildId", guildId);
                lastLocation.put("channelId", channelId);
                return buildPageWithNoTransition(
                  context: context,
                  state: state,
                  child: GuildMessagingOverview(
                    guildId: Snowflake.parse(guildId),
                    channelId: Snowflake.parse(channelId),
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: 'threads/:threadId',
                  pageBuilder: (context, state) {
                    final guildId = state.pathParameters['guildId']!;
                    final channelId = state.pathParameters['channelId']!;
                    final threadId = state.pathParameters['threadId']!;
                    var lastLocation = Hive.box("last-location");
                    lastLocation.put("guildId", guildId);
                    lastLocation.put("channelId", channelId);
                    lastLocation.put("threadId", threadId);
                    return buildPageWithNoTransition(
                      context: context,
                      state: state,
                      child: GuildMessagingOverview(
                        guildId: Snowflake.parse(guildId),
                        channelId: Snowflake.parse(channelId),
                        threadId: Snowflake.parse(threadId),
                      ),
                    );
                  },
                ),
              ],
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
