import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_members.g.dart';

@riverpod
class VoiceMembers extends _$VoiceMembers {
  AuthUser? user;

  @override
  Future<void> build(Guild guild, Channel channel) async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();

    if (authOutput is AuthUser) {
      user = authOutput;

      // print("voice state update!");

      // user!.client.onVoiceStateUpdate.listen((event) {
      //   print(event.state.member?.user?.username);
      // });
    }
  }
}
