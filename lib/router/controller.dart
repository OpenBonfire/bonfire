import 'package:bonfire/features/auth/views/login.dart';
import 'package:bonfire/features/overview/views/home.dart';
import 'package:go_router/go_router.dart';

final routerController = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    )
  ],
);
