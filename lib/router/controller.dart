import 'package:bonfire/features/channels/views/guild_channel.dart';
import 'package:bonfire/features/friends/views/friends.dart';
import 'package:firebridge/firebridge.dart';
import 'package:go_router/go_router.dart';
import 'package:bonfire/features/authentication/views/login.dart';

final routerController = GoRouter(
  initialLocation: "/app",
  routes: [
    GoRoute(path: '/app', redirect: (context, state) => "/login"),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/channels', redirect: (context, state) => "/channels/@me"),
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
            return GuildChannelScreen(guildId: snowflake, channelId: channelId);
          },
        ),
      ],
    ),
  ],
);
