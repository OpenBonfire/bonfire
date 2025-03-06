import 'dart:math';

import 'package:bonfire/features/auth/data/hive.dart';
import 'package:bonfire/features/notifications/controllers/firebase.dart';
import 'package:bonfire/features/notifications/controllers/notification.dart';
import 'package:bonfire/router/controller.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bonfire/shared/utils/web_utils/web_utils.dart'
    if (dart.library.io) 'package:bonfire/shared/utils/web_utils/non_web_utils.dart';

const firebaseOptions = FirebaseOptions(
  // hey guys, don't mind me... Just chillin here.
  apiKey: "AIzaSyCY8pVLbcOlWDz6NdLbaGckvwhOmfNu02U",
  appId: "1:162066849712:android:db38e83be74de1b6",
  messagingSenderId: "162066849712",
  projectId: "adept-ethos-91518",
);

void main() async {
  print("Starting app...");

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

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  await setupHive();

  await Firebase.initializeApp(
    name: 'bonfire',
    options: firebaseOptions,
  );

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
  print('Notification permissions: ${settings.authorizationStatus}');

  runApp(const ProviderScope(
    child: MaterialApp(
      home: MainWindow(),
    ),
  ));
}

class MainWindow extends ConsumerStatefulWidget {
  const MainWindow({super.key});

  @override
  ConsumerState<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends ConsumerState<MainWindow> {
  @override
  void initState() {
    super.initState();

    // flutterLocalNotificationsPlugin.show(
    //   Random().nextInt(10000000) + 1000,
    //   "Test Notification",
    //   "This is a test notification",
    //   NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       channel.id,
    //       channel.name,
    //       channelDescription: channel.description,
    //       icon: 'app_icon',
    //     ),
    //   ),
    //   payload: "test_payload",
    // );
  }

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
      body: Stack(
        children: [
          Column(
            children: [
              Flexible(
                child: KeyboardSizeProvider(
                  child: MaterialApp.router(
                    title: 'Bonfire',
                    theme: ref.read(darkThemeProvider),
                    darkTheme: ref.read(darkThemeProvider),
                    routerConfig: routerController,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
