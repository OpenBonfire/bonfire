import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/shared/models/channel.dart';
import 'package:bonfire/shared/models/guild.dart';
import 'package:nyxx_extensions/nyxx_extensions.dart';
import 'package:nyxx_self/nyxx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';

part 'channels.g.dart';

@riverpod
class Channels extends _$Channels {
  int? guildId;
  List<BonfireChannel> channels = [];

  @override
  Future<List<BonfireChannel>> build() async {
    var currentGuild = ref.watch(guildControllerProvider);
    var auth = ref.watch(authProvider.notifier).getAuth();

    List<BonfireChannel> _channels = [];
    if (currentGuild != null) {
      if (auth != null && auth is AuthUser) {
        print("Start member fetch");
        var selfMember =
            await auth.client.guilds.client.users.fetchCurrentUserMember(
          Snowflake(currentGuild),
        );
        print("end member fetch");

        var rawGuildChannels = await auth.client.guilds.fetchGuildChannels(
          Snowflake(currentGuild),
        );

        print("Start parse");
        var guildChannels = [];
        for (var channel in rawGuildChannels) {
          var permissions = await computePermissions(channel, selfMember);
          if (permissions.canViewChannel) {
            guildChannels.add(channel);
          }
        }
        print("end parse");

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

        _channels.sort((a, b) => a.position.compareTo(b.position));
        channels = _channels;
        state = AsyncValue.data(channels);
      }
    }
    return channels;
  }
}
