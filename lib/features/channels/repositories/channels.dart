import 'dart:convert';

import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:firebridge/firebridge.dart';

part 'channels.g.dart';

/// A riverpod provider that fetches the channels for the current guild.
@riverpod
class Channels extends _$Channels {
  List<Channel> channels = [];
  Map<UserGuild, Member> selfMembers = {};
  final _cacheManager = CacheManager(
    Config(
      'bonfire_channel_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 10000,
    ),
  );

  @override
  Future<List<Channel>> build(Guild guild) async {
    var lastGuild;
    var auth = ref.watch(authProvider.notifier).getAuth();

    List<Channel> _channels = [];
    var cachedChannels = (await fetchFromCache());
    if (cachedChannels != null) {
      if (cachedChannels.isNotEmpty) {
        channels = cachedChannels;
        lastGuild = guild;
        state = AsyncValue.data(channels);
      }
    }

    if (auth != null && auth is AuthUser) {
      if (selfMembers[guild] == null) {
        selfMembers[guild] =
            await auth.client.guilds[guild.id].members.get(auth.client.user.id);
      }

      var selfMember = selfMembers[guild]!;
      var rawGuildChannels = await auth.client.guilds.fetchGuildChannels(
        guild.id,
      );

      List<GuildChannel> guildChannels = [];

      // filter out channels that the user can't view
      for (var channel in rawGuildChannels) {
        var permissions = await channel.computePermissionsFor(selfMember);
        if (permissions.canViewChannel) {
          guildChannels.add(channel);
        }
      }

      runPrecache(guildChannels);

      // first load categories, so we can parent channels later
      for (var channel in guildChannels) {
        if (channel.type == ChannelType.guildCategory) {
          _channels.add(channel);
        }
      }

      // load channels, parenting them to their categories if applicable
      for (var channel in guildChannels) {
        if (channel.type != ChannelType.guildCategory) {
          _channels.add(channel);
        }
      }

      // sorts the channels by position (provided by nyxx)
      _channels.sort((a, b) {
        return (a as GuildChannel)
            .position
            .compareTo((b as GuildChannel).position);
      });
      channels = _channels;
      // saveToCache(channels);
      state = AsyncValue.data(channels);
    }

    return channels;
  }

  Future<void> saveToCache(List<Channel> channels) async {
    // UserGuild? guildId = ref.read(guildControllerProvider);
    // if (guildId != null) {
    //   var cacheKey = "channels_$guildId";
    //   await _cacheManager.putFile(
    //     cacheKey,
    //     utf8.encode(json.encode(channels.map((e) => e.toJson()).toList())),
    //   );
    // }
  }

  Future<List<Channel>?> fetchFromCache() async {
    // UserGuild? guildId = ref.read(guildControllerProvider);
    // print(guildId);
    // if (guildId != null) {
    //   var cacheKey = "channels_$guildId";
    //   var cacheData = await _cacheManager.getFileFromCache(cacheKey);
    //   if (cacheData != null) {
    //     var decoded =
    //         json.decode(utf8.decode(cacheData.file.readAsBytesSync()));

    //     var mapped = (decoded.map((e) => BonfireChannel.fromJson(e)).toList());

    //     return List<BonfireChannel>.from(mapped);
    //   }
    // }
    return null;
  }

  Future<void> runPrecache(List<GuildChannel> channels) async {
    // for (var channel in channels) {
    //   try {
    //     ref.read(messagesProvider.notifier).runPreCacheRoutine(channel);
    //   } catch (e) {
    //     print("error while pre-caching!");
    //     print(e);
    //   }
    // }
  }
}
