import 'dart:async';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'realtime_messages.g.dart';

@Riverpod(keepAlive: true)
Stream<List<Message>> realtimeMessages(RealtimeMessagesRef ref) async* {
  var auth = ref.watch(authProvider.notifier).getAuth();
  var messageQueue = <Message>[];

  if (auth is AuthUser) {
    var client = auth.client;
    await for (final event in client.onMessageCreate) {
      messageQueue.add(event.message);
      // print(event.message.content);

      if (messageQueue.length > 30) {
        messageQueue.removeAt(0);
      }

      yield List.from(messageQueue);
    }
  }
}
