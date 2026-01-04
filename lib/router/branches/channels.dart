import 'package:bonfire/features/channels/views/channel_router_wrapper.dart';
import 'package:bonfire/features/channels/views/guild_channel.dart';
import 'package:bonfire/features/friends/views/friends.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _channelsKey = GlobalKey<NavigatorState>(debugLabel: "Channels");

final channelsNavigationBranch = StatefulShellBranch(
  navigatorKey: _channelsKey,
  routes: [
    GoRoute(path: '/channels', redirect: (context, state) => "/channels/@me"),
    ShellRoute(
      builder: (context, state, child) {
        final rawGuildId = state.pathParameters["guildId"];
        final rawChannelId = state.pathParameters["channelId"];

        Snowflake? guildId;
        Snowflake? channelId;
        if (rawGuildId != null && rawGuildId != "@me") {
          guildId = Snowflake.parse(rawGuildId);
        }

        if (rawChannelId != null) {
          channelId = Snowflake.parse(rawChannelId);
        }

        return ChannelRouterWrapper(
          guildId: guildId,
          channelId: channelId,
          child: child,
        );
      },
      routes: [
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
              path: ":channelId",
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
