import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/current_guild.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_members.g.dart';

@riverpod
class VoiceMembers extends _$VoiceMembers {
  AuthUser? user;

  @override
  Future<void> build() async {
    final currentChannel = ref.watch(channelControllerProvider);
    final currentGuild = ref.watch(currentGuildControllerProvider);
    var authOutput = ref.watch(authProvider.notifier).getAuth();

    if (authOutput is AuthUser) {
      user = authOutput;

      print("voice state update!");

      user!.client.onVoiceStateUpdate.listen((event) {
        print(event.state.member?.user?.username);
      });
    }
  }
}
