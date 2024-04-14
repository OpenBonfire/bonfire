import 'package:bonfire/themes/dark.dart';
import 'package:bonfire/views/home.dart';
import 'package:bonfire/views/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyxx/nyxx.dart';
import 'dart:io';

void main() async {
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
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => const Home(),
      },
    );
  }
}