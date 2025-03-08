import 'package:bonfire/features/auth/controllers/ready.dart';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/channels/repositories/channels.dart';
import 'package:bonfire/features/channels/repositories/has_unreads.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guild_unreads.g.dart';

@Riverpod(keepAlive: true)
class GuildUnreads extends _$GuildUnreads {
  @override
  bool build(Snowflake guildId) {
    // TODO: Guilds start null, so I need to listen for them to be ready.

    // bool isReady = ref.watch(readyControllerProvider);
    // if (!isReady) {
    //   return false;
    // }
    Guild? guild = ref.watch(guildControllerProvider(guildId));
    if (guild == null) {
      // print("Guild is null");
      return false;
    }
    var channels = ref.watch(channelsProvider(guildId)).valueOrNull ?? [];
    // print("GOT CHANNELS: ${channels.length}");

    for (var channel in channels) {
      if (channel is GuildTextChannel) {
        //         var unread = await ref.watch(hasUnreadsProvider(channel).future);
        // if (unread) return true;
        // var unread = ref.watch(hasUnreadsProvider(channel.id));
        // return unread.valueOrNull ?? false;
      }
    }

    return false;
  }
}
