import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'join.g.dart';

@Riverpod()
@override
class VoiceChannelController extends _$VoiceChannelController {
  AuthUser? user;

  @override
  Future<void> build() async {
    var authUser = ref.watch(authProvider.notifier).getAuth();
    if (authUser is AuthUser) {
      user = authUser;
    }
  }

  void joinVoiceChannel(Snowflake guildId, Snowflake channelId) {
    if (user == null) {
      print("no auth, can't join VC");
      return;
    }

    print("joining VC");

    try {
      user!.client.updateVoiceState(
          guildId,
          GatewayVoiceStateBuilder(
            channelId: channelId,
            isMuted: false,
            isDeafened: false,
            isStreaming: false,
          ));
    } catch (e) {
      print("error joining VC: $e");
    }
  }
}
