import 'dart:convert';

import 'package:bonfire/features/auth/data/hive.dart';
import 'package:bonfire/features/notifications/controllers/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce/hive.dart';

const firebaseOptions = FirebaseOptions(
  // hey guys, don't mind me... Just chillin here.
  apiKey: "AIzaSyCY8pVLbcOlWDz6NdLbaGckvwhOmfNu02U",
  appId: "1:162066849712:android:db38e83be74de1b6",
  messagingSenderId: "162066849712",
  projectId: "adept-ethos-91518",
);

void showNotification(RemoteMessage message) async {
  final notification = message.notification;

  var auth = await Hive.openBox('auth');
  var token = auth.get('token');

  if (token == null) {
    print("Saved token is null which doesn't make a lot of sense...");
    return;
  }

  final client = await Nyxx.connectRest(token);
  // final client = await Nyxx.connectGatewayWithOptions(
  //     GatewayApiOptions(
  //       token: token,
  //       intents: GatewayIntents.all,
  //       compression: GatewayCompression.none,
  //     ),
  //     GatewayClientOptions(
  //       plugins: [
  //         Logging(logLevel: Level.SEVERE),
  //       ],
  //     ));

  final notificationData =
      client.gateway.parseNotificationCreated(message.data);

  print("parsed!");

  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notificationData.username,
    notificationData.messageContent,
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

Future<void> setupFirebaseMessaging() async {
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Foreground message received: ${message.messageId}');
  //   showNotification(message);
  // });
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: firebaseOptions);
  await initializeNotifications();
  await setupHive();
  showNotification(message);
  print('Background message handled: ${jsonEncode(message.data)}');
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
