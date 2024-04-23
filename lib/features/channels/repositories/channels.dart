import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/shared/models/channel.dart';
import 'package:bonfire/shared/models/guild.dart';
import 'package:nyxx_extensions/nyxx_extensions.dart';
import 'package:nyxx_self/nyxx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';

part 'channels.g.dart';

/// A riverpod provider that fetches the channels for the current guild.
@riverpod
class Channels extends _$Channels {
  int? guildId;
  List<BonfireChannel> channels = [];
  Map<int, Member> selfMembers = {};

  Future<void> runPrecache(List<GuildChannel> channels) async {
    for (var channel in channels) {
      try {
        await ref.read(messagesProvider.notifier).runPreCacheRoutine(channel);
      } catch (e) {
        print("error while pre-caching!");
        print(e);
      }
      await Future.delayed(const Duration(milliseconds: 2000));
    }
  }

  @override
  Future<List<BonfireChannel>> build() async {
    var currentGuild = ref.watch(guildControllerProvider);
    var auth = ref.watch(authProvider.notifier).getAuth();

    List<BonfireChannel> _channels = [];
    if (currentGuild != null) {
      if (auth != null && auth is AuthUser) {
        if (selfMembers[currentGuild] == null) {
          selfMembers[currentGuild] = await auth
              .client.guilds[Snowflake(currentGuild)].members
              .get(auth.client.user.id);
        }

        var selfMember = selfMembers[currentGuild]!;
        var rawGuildChannels = await auth.client.guilds.fetchGuildChannels(
          Snowflake(currentGuild),
        );

        List<GuildChannel> guildChannels = [];

        // filter out channels that the user can't view
        for (var channel in rawGuildChannels) {
          var permissions = await channel.computePermissionsFor(selfMember);
          if (permissions.canViewChannel) {
            guildChannels.add(channel);
          }
        }
        // runPrecache(guildChannels);

        // first load categories, so we can parent channels later
        for (var channel in guildChannels) {
          if (channel.type == ChannelType.guildCategory) {
            var newChannel = BonfireChannel(
              id: channel.id.value,
              name: channel.name,
              parent: null,
              position: channel.position,
              type: BonfireChannelType.values.firstWhere(
                (element) => element.value == channel.type.value,
              ),
            );
            _channels.add(newChannel);
          }
        }

        // load channels, parenting them to their categories if applicable
        for (var channel in guildChannels) {
          if (channel.type != ChannelType.guildCategory) {
            var parentChannel = _channels.firstWhereOrNull(
              (element) => element.id == channel.parentId?.value,
            );

            var newChannel = BonfireChannel(
              id: channel.id.value,
              name: channel.name,
              parent: parentChannel,
              position: channel.position,
              type: BonfireChannelType.values.firstWhere(
                (element) => element.value == channel.type.value,
              ),
            );

            _channels.add(newChannel);
          }
        }

        // sorts the channels by position (provided by nyxx)
        _channels.sort((a, b) => a.position.compareTo(b.position));
        channels = _channels;
        state = AsyncValue.data(channels);
      }
    }
    return channels;
  }
}
