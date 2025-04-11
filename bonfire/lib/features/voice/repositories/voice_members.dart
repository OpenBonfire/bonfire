import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/guild/controllers/guilds.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/foundation.dart';
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
    var authOutput = ref.watch(authProvider);
    if (authOutput is AuthUser) {
      user = authOutput;
      Guild voiceGuild = ref
          .watch(guildsControllerProvider)!
          .firstWhere((element) => element.id == guildId);

      var allStates = voiceGuild.voiceStates.entries.toList();

      if (channelId != null) {
        var filteredStates = allStates
            .where((element) => element.value.channelId == channelId)
            .toList();
        state = AsyncData(filteredStates);
        return filteredStates;
      } else {
        state = AsyncData(allStates);
        return allStates;
      }
    }
    return null;
  }

  void processVoiceStateUpdate(VoiceStateUpdateEvent event) {
    Guild? voiceGuild = ref.watch(guildControllerProvider(guildId));
    if (voiceGuild == null) {
      debugPrint("bad guild ($guildId), cannot process voice state update");
      return;
    }

    VoiceState currentState = event.state;
    VoiceState? lastState = event.oldState;

    List<MapEntry<Snowflake, VoiceState>>? currentStates = state.asData?.value;
    if (currentStates == null) return;

    test(element) => element.key == currentState.userId;
    currentStates.removeWhere(test);

    if (currentState.channelId != null) {
      currentStates.add(MapEntry(currentState.userId, currentState));
    }
    if ((lastState?.channelId == channelId)) {
      state = AsyncData(currentStates);
    }
  }
}
