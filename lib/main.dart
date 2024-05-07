import 'dart:io';

import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/router/controller.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]);

  await GetStorage.init();
  runApp(const ProviderScope(child: MaterialApp(home: MainWindow())));
}

class MainWindow extends ConsumerStatefulWidget {
  const MainWindow({Key? key}) : super(key: key);

  @override
  ConsumerState<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends ConsumerState<MainWindow> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));

    return MaterialApp.router(
      title: 'Bonfire',
      theme: ref.read(lightThemeProvider),
      darkTheme: ref.read(darkThemeProvider),
      routerConfig: routerController,
    );
  }
}
