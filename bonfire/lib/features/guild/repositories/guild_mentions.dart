import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'guild_mentions.g.dart';

@Riverpod(keepAlive: true)
class GuildMentions extends _$GuildMentions {
  @override
  Future<int> build(Snowflake guildId) async {
    var user = ref.watch(authProvider.notifier).getAuth();
    if (user is! AuthUser) return 0;

    AsyncValue<List<Guild>?> guilds = ref.watch(guildsStateProvider);

    // we want to retrieve the guild from settings as it
    // has all of the channels
    var currentGuild =
        guilds.valueOrNull?.firstWhereOrNull((g) => g.id == guildId);
    var channels = currentGuild?.channels ?? [];

    if (currentGuild == null) return 0;

    int mentions = 0;
    // var selfMember = await user.client.guilds[currentGuild.id].members
    //     .get(user.client.user.id);
    for (var channel in channels) {
      var readStateProvider = ref.watch(channelReadStateProvider(channel.id));
      // if (channel is! GuildTextChannel) continue;
      try {
        // if (channel is GuildTextChannel) {
        ReadState? readState = readStateProvider;
        if (readState == null) continue;

        mentions += readState.mentionCount ?? 0;
        // }
      } catch (err, stacktrace) {
        debugPrint(stacktrace.toString());
        debugPrint("Error fetching channel: $err");
        continue;
      }
    }

    return mentions;
  }
}
