import 'dart:async';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/shared/models/member.dart';
import 'package:bonfire/shared/models/message.dart';
import 'package:bonfire/shared/utils/message.dart';
import 'package:nyxx_self/nyxx.dart' as nyxx;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'realtime_messages.g.dart';

@riverpod
Stream<List<BonfireMessage>> realtimeMessages(RealtimeMessagesRef ref) async* {
  var auth = ref.watch(authProvider.notifier).getAuth();
  var messageQueue = <BonfireMessage>[];

  if (auth != null && auth is AuthUser) {
    var client = auth.client;
    await for (final event in client.onMessageCreate) {
      var message =
          await MessageConverter.convert(event.message, event.guildId!.value);
      // var message = BonfireMessage(
      //   id: event.message.id.value,
      //   content: event.message.content,
      //   timestamp: event.message.timestamp,
      //   member: BonfireGuildMember(
      //     id: event.message.author.id.value,
      //     displayName: event.message.author.username,
      //     // warning: I think guildId is null for DMs!
      //     // this needs to be handled properly
      //     guildId: event.guildId!.value,
      //     name: event.message.author.username,
      //   ),
      // );

      messageQueue.add(message);

      if (messageQueue.length > 30) {
        messageQueue.removeAt(0);
      }

      yield List.from(messageQueue.reversed);
    }
  }
}
