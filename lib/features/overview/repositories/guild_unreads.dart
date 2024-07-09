import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/has_unreads.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guild_unreads.g.dart';

@Riverpod(keepAlive: true)
class GuildUnreads extends _$GuildUnreads {
  @override
  Future<bool> build(Snowflake guildId) async {
    List<Guild> guilds = ref.watch(guildsStateProvider) ?? [];
    var currentGuild = guilds.firstWhere((g) => g.id == guildId);
    var channels = currentGuild.channels!;

    for (var channel in channels) {
      if (channel is GuildTextChannel) {
        var unread = await ref.watch(hasUnreadsProvider(channel).future);
        if (unread) {
          return true;
        }
      }
    }

    return false;
  }
}
