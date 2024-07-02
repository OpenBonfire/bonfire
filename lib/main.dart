import 'dart:io';

import 'package:bonfire/router/controller.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bonfire/features/window/views/window.dart';

void main() async {
  VideoPlayerMediaKit.ensureInitialized(
    android: true,
    iOS: true,
    macOS: true,
    windows: true,
    linux: true,
  );

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top]);

  await GetStorage.init();
  runApp(const ProviderScope(child: MaterialApp(home: MainWindow())));

  if (Platform.isWindows | Platform.isLinux | Platform.isMacOS) {
    doWhenWindowReady(() {
      const initialSize = Size(1280, 720);
      // appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class MainWindow extends ConsumerStatefulWidget {
  const MainWindow({super.key});

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
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          (Platform.isWindows | Platform.isLinux | Platform.isMacOS)
              ? const WindowTopBar()
              : Container(), // Use the new WindowTopBar widget
          Flexible(
            child: KeyboardSizeProvider(
              child: MaterialApp.router(
                title: 'Bonfire',
                theme: ref.read(lightThemeProvider),
                darkTheme: ref.read(darkThemeProvider),
                routerConfig: routerController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
