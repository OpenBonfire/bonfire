import 'dart:math';

import 'package:bonfire/firebase_options.dart';
import 'package:bonfire/router/controller.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

import 'package:bonfire/shared/utils/web_utils/web_utils.dart'
    if (dart.library.io) 'package:bonfire/shared/utils/web_utils/non_web_utils.dart';

const firebaseOptions = FirebaseOptions(
  // hey guys, don't mind me... Just chillin here.
  apiKey: "AIzaSyCY8pVLbcOlWDz6NdLbaGckvwhOmfNu02U",
  appId: "1:653247688936:android:d573298672d5315d05595d",
  messagingSenderId: "653247688936",
  projectId: "bonfire-app-dev",
);

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
late AndroidNotificationChannel channel;

Future<void> initializeNotifications() async {
  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: initializationSettingsAndroid,
    ),
  );

  final androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(channel);
}

void showFlutterNotification(RemoteMessage message) {
  print("Showing notification");
  print("Notification: ${message.notification}");
  print("Android: ${message.notification?.android}");
  final notification = message.notification;
  final android = message.notification?.android;
  print("Data: ${message.data}");
  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    "Notification Title",
    "Notification Body",
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: 'app_icon',
      ),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: firebaseOptions);
  await initializeNotifications();
  showFlutterNotification(message);
  print('Background message handled: ${message.messageId}');
}

Future<void> setupFirebaseMessaging() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground message received: ${message.messageId}');
    showFlutterNotification(message);
  });
}

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

  if (!UniversalPlatform.isWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${appDocumentDir.path}/bonfire/data');
    if (!dataDir.existsSync()) {
      dataDir.createSync(recursive: true);
    }
    Hive.init(dataDir.path);
  }

  await Hive.openBox("auth");
  await Hive.openBox("last-location");
  await Hive.openBox("last-guild-channels");
  await Hive.openBox("added-accounts");

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
  print('Notification permissions: ${settings.authorizationStatus}');

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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

    flutterLocalNotificationsPlugin.show(
      Random().nextInt(10000000) + 1000,
      "Test Notification",
      "This is a test notification",
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'app_icon',
        ),
      ),
      payload: "test_payload",
    );
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
