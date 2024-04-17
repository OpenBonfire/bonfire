import 'package:bonfire/network/auth.dart';
import 'package:bonfire/themes/dark.dart';
import 'package:bonfire/views/home/home.dart';
import 'package:bonfire/views/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nyxx/nyxx.dart';
import 'package:bonfire/colors.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  ));
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor:
          foreground, // This makes navigation bar transparent
      systemNavigationBarIconBrightness:
          Brightness.dark, // You can set the icons' color to dark
      statusBarColor:
          Colors.transparent, // This makes the status bar transparent
    ));
    return MaterialApp(
      theme: darkTheme,
      home: _buildInitialRouteWidget(),
    );
  }

  Widget _buildInitialRouteWidget() {
    return Navigator(
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (context) => LoginPage());
        } else if (settings.name == '/home') {
          final NyxxGateway client = settings.arguments as NyxxGateway;
          return MaterialPageRoute(builder: (context) => Home(client: client));
        }
      },
      initialRoute: "/login",
    );
  }
}
