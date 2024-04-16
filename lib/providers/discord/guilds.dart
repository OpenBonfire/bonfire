import 'package:bonfire/globals.dart';
import 'package:bonfire/views/home/messages/messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyxx/nyxx.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guilds.g.dart';

@riverpod
Future<List<UserGuild>> guilds(GuildsRef ref, NyxxGateway client) async {
  return await client.listGuilds();
}

@riverpod
Future<Guild> guild(GuildRef ref, NyxxGateway client, Snowflake id) async {
  return await client.guilds.fetch(id, withCounts: true);
}

@riverpod
Future<List<GuildChannel>> channels(
    ChannelsRef ref, NyxxGateway client, UserGuild guild) async {
  return await guild.fetchChannels();
}

// @Riverpod(keepAlive: false)
// Future<List<Message>> messages(
//     MessagesRef ref, NyxxGateway client, GuildChannel channel) async {
//   return client.channels.cache[channel.id]!.fetch(limit: 50)
// }
