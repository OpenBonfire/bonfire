import 'dart:convert';

import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/guild/controllers/role.dart';
import 'package:bonfire/features/guild/controllers/roles.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channels.g.dart';

/// A riverpod provider that fetches the channels for the current guild.
@Riverpod(keepAlive: true)
class Channels extends _$Channels {
  final _cacheManager = CacheManager(
    Config(
      'channel_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 10000,
    ),
  );

  @override
  Future<List<Channel>> build(Snowflake guildId) async {
    List<Channel> channels = [];
    var auth = ref.watch(authProvider.notifier).getAuth();
    Guild? guild = ref.watch(guildControllerProvider(guildId));

    if (guild == null) {
      return [];
    }

    if (auth != null && auth is AuthUser) {
      // var rawGuildChannels = await auth.client.guilds.fetchGuildChannels(
      //   guild.id,
      // );

      // works because the onready event has the channels already
      // will desync since I don't support sync updates for channels
      var rawGuildChannels = guild.channels!;

      List<GuildChannel> guildChannels = [];

      // print("Member List: ${guild.memberList?.length}");
      Member? maybeSelf;
      Member? selfMember;
      guild.memberList?.forEach((element) {
        if (element.user?.id == auth.client.user.id) {
          maybeSelf = element;
        }
        // print("Member: ${element.user.username}");
      });

      if (maybeSelf != null) {
        selfMember = maybeSelf;
      } else {
        // shouldn't really be called
        selfMember =
            await auth.client.guilds[guild.id].members.get(auth.client.user.id);
      }

      var roleIds = ref.watch(rolesControllerProvider(guildId));
      if (roleIds == null) {
        print("No role ids");
      }

      List<Role> roles = [];
      for (Snowflake roleId in roleIds!) {
        var r = ref.watch(roleControllerProvider(roleId));
        roles.add(r!);
      }

      // filter out channels that the user can't view
      for (var channel in rawGuildChannels) {
        var permissions =
            await channel.computePermissionsForMemberWithGuildAndRoles(
          selfMember!,
          guild,
          roles,
        );
        if (permissions.canViewChannel) {
          guildChannels.add(channel);
        }
      }

      // first load categories, so we can parent channels later
      for (var channel in guildChannels) {
        if (channel.type == ChannelType.guildCategory) {
          channels.add(channel);
        }
      }

      // load channels, parenting them to their categories if applicable
      for (var channel in guildChannels) {
        if (channel.type != ChannelType.guildCategory) {
          channels.add(channel);
        }
      }

      // sorts the channels by position (provided by nyxx)
      channels.sort((a, b) {
        return (a as GuildChannel)
            .position
            .compareTo((b as GuildChannel).position);
      });

      // state = AsyncValue.data(channels);
    }

    return channels;
  }

  Future<List<Channel>?> fetchFromCache() async {
    var cacheKey = "channels_${guildId.value}";
    var cacheData = await _cacheManager.getFileFromCache(cacheKey);
    Guild guild = ref.watch(guildControllerProvider(guildId))!;
    if (cacheData != null) {
      var decoded = json.decode(utf8.decode(cacheData.file.readAsBytesSync()));

      var mapped =
          (decoded.map((e) => guild.manager.client.channels.parse(e)).toList());

      return List<Channel>.from(mapped);
    }

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
