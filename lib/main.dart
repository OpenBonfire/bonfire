import 'package:bonfire/features/authentication/utils/hive.dart';
import 'package:bonfire/features/notifications/controllers/firebase.dart';
import 'package:bonfire/features/notifications/controllers/notification.dart';
import 'package:bonfire/router/controller.dart';
import 'package:bonfire/theme/themes/base.dart';
import 'package:bonfire/theme/themes/dark.dart';
import 'package:bonfire/theme/themes/light.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebridge/firebridge.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_transitions/go_transitions.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bonfire/shared/utils/web_utils/web_utils.dart'
    if (dart.library.io) 'package:bonfire/shared/utils/web_utils/non_web_utils.dart';

void main() async {
  debugPrint("Starting app...");

  initializePlatform();

  VideoPlayerMediaKit.ensureInitialized(
    android: true,
    iOS: true,
    macOS: true,
    windows: true,
    linux: true,
    web: true,
  );

  WidgetsFlutterBinding.ensureInitialized();
  Firebridge.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  await setupHive();

  // TODO: Add iOS support
  // Notifications for other platforms like Windows will be added,
  // but I don't believe any of that is handled via firebase
  // Because desktop is way less locked down, it probably has
  // some other notifer endpoint that doesn't rely on the system
  if (UniversalPlatform.isAndroid) {
    await Firebase.initializeApp(name: 'bonfire', options: firebaseOptions);
    await initializeNotifications();
    await setupFirebaseMessaging();

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    registerBackgroundHandler();
    debugPrint('Notification permissions: ${settings.authorizationStatus}');
  }

  runApp(const ProviderScope(child: MaterialApp(home: MainWindow())));
}

class MainWindow extends ConsumerStatefulWidget {
  const MainWindow({super.key});

  @override
  ConsumerState<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends ConsumerState<MainWindow> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    final pageTransition = const PageTransitionsTheme(
      builders: {
        // TargetPlatform.android: GoTransitions.material,
        TargetPlatform.fuchsia: GoTransitions.none,
        TargetPlatform.iOS: GoTransitions.none,
        TargetPlatform.linux: GoTransitions.none,
        TargetPlatform.macOS: GoTransitions.none,
        TargetPlatform.windows: GoTransitions.none,
      },
    );

    return MaterialApp.router(
      themeMode: ThemeMode.dark,
      title: 'EpicHire',
      theme: ThemeData(
        colorScheme: lightColorScheme,
        textTheme: getBaseTextTheme(),
        pageTransitionsTheme: pageTransition,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        textTheme: getBaseTextTheme(),
        pageTransitionsTheme: pageTransition,
      ),
      routerConfig: routerController,
      builder: (context, child) {
        return Container(child: child);
      },
    );
  }
}
