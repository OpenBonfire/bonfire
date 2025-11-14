import 'dart:io';

import 'package:firebridge/firebridge.dart';

void main() async {
  final client = await Nyxx.connectGateway(
    Platform.environment['TOKEN']!,
    GatewayIntents.all,
    options: GatewayClientOptions(plugins: [logging, cliIntegration]),
  );

  // on message sent
  // client.onMessageCreate.listen((event) async {
  //   if (event.message.content.contains('nyxx_firebridge')) {
  //     var memberList = await members.toList();
  //     debugPrint(memberList);
  //   }
  // });

  client.onGuildMemberListUpdate.listen((event) async {
    // debugPrint("new event just dropped");
    // debugPrint(event);
  });

  // var memberList = await members.toList();
  // debugPrint(memberList);

  // client.onMessageCreate.listen((event) async {
  //   if (event.message.content.contains('nyxx_firebridge')) {

  //   }
  // });
}
