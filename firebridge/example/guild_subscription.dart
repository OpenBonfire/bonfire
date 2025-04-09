import 'package:firebridge/firebridge.dart';

String gatewayToken = "";

void main() async {
  final client = await Nyxx.connectGateway(
    gatewayToken,
    GatewayIntents.all,
    options: GatewayClientOptions(
        plugins: [Logging(logLevel: Level.OFF), cliIntegration]),
  );

  client.onMessageCreate.listen((event) async {
    // debugPrint("GOT MESSAGE!");
    // debugPrint(DiscordDateUtils.packLastViewed(DateTime.now()));
    event.message.manager.acknowledge(event.message.id);
  });

  client.onChannelUnread.listen((event) async {
    // debugPrint("got unread!");
    // debugPrint(event.channelUnreadUpdates.first.readState.lastViewed);
  });

  client.onMessageAck.listen((event) async {
    // debugPrint("got ack!");
    // debugPrint(event.channel);
    // debugPrint("GOT ACK!");
    // debugPrint(event.messageId);
  });

  client.onRelationshipAdd.listen((event) async {
    print("got relationship add!");
    print(event.relationship.user);
  });

  client.onRelationshipRemove.listen((event) async {
    print("got relationship remove!");
    print(event.id);
  });

  client.onRelationshipUpdate.listen((event) async {
    print("got relationship update!");
    print(event.id);
  });

  client.onReady.listen((event) async {
    print("Client Ready");
    // debugPrint("Ready!");

    // Snowflake guildId = Snowflake(BigInt.from(603970300668805120));
    // Snowflake channelId = Snowflake(BigInt.from(1085672960695746600));

    // // get channel
    // ForumChannel channel = await client.channels.get(channelId) as ForumChannel;
    // var singleThread = await channel.manager
    //     .getThreadPostData(channelId, [Snowflake.parse(1152257066656858184)]);
    // debugPrint(singleThread.first.firstMessage);
  });
}
