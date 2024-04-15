import 'package:bonfire/network/auth.dart';
import 'package:bonfire/themes/dark.dart';
import 'package:bonfire/views/home/home.dart';
import 'package:bonfire/views/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nyxx/nyxx.dart';
import 'dart:io';

void main() async {
  await GetStorage.init();
  runApp(const ProviderScope(child: NavigatorWidget()));
}

class NavigatorWidget extends StatefulWidget {
  const NavigatorWidget({super.key});

  @override
  State<NavigatorWidget> createState() => _NavigatorWidgetState();
}

class _NavigatorWidgetState extends State<NavigatorWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (context) => LoginPage());
        } else if (settings.name == '/home') {
          // Extract arguments if available
          final NyxxGateway client = settings.arguments as NyxxGateway;
          return MaterialPageRoute(builder: (context) => Home(client: client));
        }
      },
      initialRoute: "/login",
    );
  }
}

/*
routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => const Home(),
      },
      initialRoute: "/login",
*/
