import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_members.g.dart';

@Riverpod(keepAlive: true)
class VoiceMembers extends _$VoiceMembers {
  AuthUser? user;

  @override
  Future<List<MapEntry<Snowflake, VoiceState>>?> build(
    Snowflake guildId, {
    Snowflake? channelId,
  }) async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();

    if (authOutput is AuthUser) {
      user = authOutput;
      Guild voiceGuild = ref
          .watch(guildsStateProvider)!
          .firstWhere((element) => element.id == guildId);

      // print("voice state update!");

      // user!.client.onVoiceStateUpdate.listen((event) {
      //   print(event.state.member?.user?.username);
      // });

      if (channelId != null) {
        return voiceGuild.voiceStates.entries
            .where((element) => element.value.channelId == channelId)
            .toList();
      }
      return voiceGuild.voiceStates.entries.toList();
    }

    return null;
  }

  void processVoiceStateUpdate(VoiceStateUpdateEvent event) {
    // the cache *should* update automatically for the guild, so modifying the
    // data based on the event shouldn't be necessary
    Guild? voiceGuild = ref.watch(guildControllerProvider(guildId)).valueOrNull;
    if (voiceGuild == null) {
      print("bad guild");
      return;
    }

    var currentProviderState = state;

    state = AsyncValue.data(voiceGuild.voiceStates.entries.toList());
  }
}
