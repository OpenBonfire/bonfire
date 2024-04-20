import 'package:bonfire/features/auth/views/login.dart';
import 'package:bonfire/features/auth/views/mfa.dart';
import 'package:bonfire/features/overview/views/home.dart';
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
    )
  ],
);
