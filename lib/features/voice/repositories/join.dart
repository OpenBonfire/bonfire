import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'join.g.dart';

// todo: actually listen to network state for voice join state

@Riverpod()
@override
class VoiceChannelController extends _$VoiceChannelController {
  AuthUser? user;

  @override
  bool build() {
    var authUser = ref.watch(authProvider.notifier).getAuth();
    if (authUser is AuthUser) {
      user = authUser;
    }
    return false;
  }

  void joinVoiceChannel(Snowflake guildId, Snowflake channelId) {
    user!.client.updateVoiceState(
        guildId,
        GatewayVoiceStateBuilder(
          channelId: channelId,
          isMuted: false,
          isDeafened: false,
          isStreaming: false,
        ));

    state = true;
  }

  void leaveVoiceChannel() {
    user!.client.updateVoiceState(
        Snowflake.zero,
        GatewayVoiceStateBuilder(
          channelId: null,
          isMuted: false,
          isDeafened: false,
          isStreaming: false,
        ));

    state = false;
  }
}
