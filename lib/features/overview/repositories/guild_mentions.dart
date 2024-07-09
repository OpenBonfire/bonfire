import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:collection/collection.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guild_mentions.g.dart';

@Riverpod(keepAlive: true)
class GuildMentions extends _$GuildMentions {
  @override
  Future<int> build(Snowflake guildId) async {
    var user = ref.watch(authProvider.notifier).getAuth();
    if (user is! AuthUser) return 0;

    List<Guild> guilds = ref.watch(guildsStateProvider) ?? [];
    var readStateProvider = ref.watch(channelReadStateProvider);

    var currentGuild = guilds.firstWhereOrNull((g) => g.id == guildId);
    var channels = currentGuild?.channels ?? [];

    if (currentGuild == null) return 0;

    int mentions = 0;
    // var selfMember = await user.client.guilds[currentGuild.id].members
    //     .get(user.client.user.id);
    for (var channel in channels) {
      // if (channel is! GuildTextChannel) continue;
      try {
        // if (channel is GuildTextChannel) {
        ReadState? readState = readStateProvider?[channel.id];
        if (readState == null) continue;

        mentions += readState.mentionCount;
        // }
      } catch (err, stacktrace) {
        print(stacktrace);
        print("Error fetching channel: $err");
        continue;
      }
    }

    return mentions;
  }
}
