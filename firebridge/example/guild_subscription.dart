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
    // print("GOT MESSAGE!");
    // print(DiscordDateUtils.packLastViewed(DateTime.now()));
    event.message.manager.acknowledge(event.message.id);
  });

  client.onChannelUnread.listen((event) async {
    // print("got unread!");
    // print(event.channelUnreadUpdates.first.readState.lastViewed);
  });

  client.onMessageAck.listen((event) async {
    // print("got ack!");
    // print(event.channel);
    // print("GOT ACK!");
    // print(event.messageId);
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
    // print("Ready!");

    // Snowflake guildId = Snowflake(BigInt.from(603970300668805120));
    // Snowflake channelId = Snowflake(BigInt.from(1085672960695746600));

    // // get channel
    // ForumChannel channel = await client.channels.get(channelId) as ForumChannel;
    // var singleThread = await channel.manager
    //     .getThreadPostData(channelId, [Snowflake.parse(1152257066656858184)]);
    // print(singleThread.first.firstMessage);
  });
}
