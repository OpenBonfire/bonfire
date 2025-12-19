import 'package:bonfire/features/channels/views/guild_channel.dart';
import 'package:bonfire/features/friends/views/friends.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bonfire/features/authentication/views/login.dart';

final routerController = GoRouter(
  initialLocation: "/app",
  routes: [
    ShellRoute(
      builder: (context, state, child) => Scaffold(
        body: child,
        backgroundColor: BonfireThemeExtension.of(context).background,
      ),
      routes: [
        GoRoute(path: '/app', redirect: (context, state) => "/login"),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/channels',

          redirect: (context, state) => "/channels/@me",
        ),
        GoRoute(
          path: '/channels/:guildId',
          builder: (context, state) {
            final guildId = state.pathParameters["guildId"]!;

            if (guildId == "@me") {
              return FriendsScreen();
            }

            return GuildChannelScreen(guildId: Snowflake.parse(guildId));
          },
          routes: [
            GoRoute(
              path: ":guildId",
              builder: (context, state) {
                final guildId = state.pathParameters["guildId"]!;
                final channelId = Snowflake.parse(
                  state.pathParameters["channelId"]!,
                );
                if (guildId == "@me") {
                  return FriendsScreen(channelId: channelId);
                }
                final snowflake = Snowflake.parse(guildId);
                return GuildChannelScreen(
                  guildId: snowflake,
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
