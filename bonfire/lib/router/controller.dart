import 'package:bonfire/features/authentication/views/switcher.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bonfire/features/authentication/views/login.dart';
import 'package:bonfire/features/authentication/views/mfa.dart';
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
              pageBuilder: (context, state) => CustomTransitionPage(
                key: const ValueKey('channels_route'),
                child: GuildMessagingOverview(
                  guildId: Snowflake.zero,
                  channelId: Snowflake.zero,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) => child,
              ),
            ),
            GoRoute(
              path: 'channels/:guildId/:channelId',
              pageBuilder: (context, state) {
                String guildId = state.pathParameters['guildId'] ?? '0';
                if (guildId == "@me") guildId = "0";
                final channelId = state.pathParameters['channelId']!;
                final lastLocation = Hive.box("last-location");
                lastLocation.put("guildId", guildId);
                lastLocation.put("channelId", channelId);

                return CustomTransitionPage(
                  key: const ValueKey('channels_route'),
                  child: GuildMessagingOverview(
                    guildId: Snowflake.parse(guildId),
                    channelId: Snowflake.parse(channelId),
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) => child,
                );
              },
              routes: [
                GoRoute(
                  path: 'threads/:threadId',
                  pageBuilder: (context, state) {
                    print("Navigating to thread route");
                    final guildId = state.pathParameters['guildId']!;
                    final channelId = state.pathParameters['channelId']!;
                    final threadId = state.pathParameters['threadId']!;
                    final lastLocation = Hive.box("last-location");
                    lastLocation.putAll({
                      "guildId": guildId,
                      "channelId": channelId,
                      "threadId": threadId
                    });

                    return CustomTransitionPage(
                      key: const ValueKey('threads_route'),
                      child: GuildMessagingOverview(
                        guildId: Snowflake.parse(guildId),
                        channelId: Snowflake.parse(channelId),
                        threadId: Snowflake.parse(threadId),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) =>
                              child,
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
