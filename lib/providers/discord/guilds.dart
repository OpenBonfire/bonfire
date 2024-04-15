import 'package:bonfire/globals.dart';
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
Future<List<GuildChannel>> channels(ChannelsRef ref, NyxxGateway client, Guild guild) async {
  return await guild.fetchChannels();
}