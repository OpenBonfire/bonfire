import 'dart:io';

import 'package:firebridge/firebridge.dart';

void main() async {
  String token = "";
  final client = await Nyxx.connectGateway(
    token,
    GatewayIntents.all,
    options: GatewayClientOptions(plugins: [logging, cliIntegration]),
  );

  client.channels.listDmChannels().then((value) {
    // for (var dm in value.reversed) {
    //   print(dm.recipients.first.username);
    // }
  });
}
