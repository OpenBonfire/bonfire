import 'package:nyxx/nyxx.dart';
// import dart platform system thing
import 'dart:io';

void main() async {
  final client = await Nyxx.connectGateway(Platform.environment['TEST_TOKEN']!, GatewayIntents.allUnprivileged);

  final botUser = await client.users.fetchCurrentUser();

  client.onMessageCreate.listen((event) async {
    if (event.mentions.contains(botUser)) {
      await event.message.channel.sendMessage(MessageBuilder(
        content: 'You mentioned me!',
        replyId: event.message.id,
      ));
    }
  });
}