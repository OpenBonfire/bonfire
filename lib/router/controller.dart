import 'package:bonfire/router/branches/channels.dart';
import 'package:go_router/go_router.dart';
import 'package:bonfire/features/authentication/views/login.dart';

final routerController = GoRouter(
  initialLocation: "/app",
  routes: [
    GoRoute(path: '/app', redirect: (context, state) => "/login"),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    // sidebar handler
    ShellRoute(
      builder: (context, state, child) {
        return child;
      },
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return navigationShell;
          },
          branches: [channelsNavigationBranch],
        ),
      ],
    ),
  ],
);
