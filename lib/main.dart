import 'package:bonfire/router/controller.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bonfire/features/window/views/window.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

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

  final appDocumentDir = await getApplicationDocumentsDirectory();
  final dataDir = Directory('${appDocumentDir.path}/bonfire/data');

  if (!await dataDir.exists()) {
    await dataDir.create(recursive: true);
  }

  Hive.init(dataDir.path);

  await Hive.openBox("auth");
  await Hive.openBox("last-location");
  await Hive.openBox("last-guild-channels");
  await Hive.openBox("added-accounts");

  runApp(const ProviderScope(child: MaterialApp(home: MainWindow())));

  if (UniversalPlatform.isDesktop) {
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
          (UniversalPlatform.isDesktop) ? const WindowTopBar() : Container(),
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
