import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_messages.g.dart';

/// Message provider for fetching user messages from the Discord API
@Riverpod(keepAlive: true)
class UserMessages extends _$UserMessages {
  AuthUser? user;

  @override
  Future<void> build() async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    if (authOutput is AuthUser) {
      user = authOutput;
      // print("LISTING CHANNELS!");

      // try {
      //   var channels = await user!.client.channels.listDmChannels();
      //   print("GOT CHANNNELS");
      //   print(channels);
      // } catch (e) {
      //   print("ERROR GETTING CHANNELS");
      //   print(e);
      // }

      // print("GOT CHANNNELS1");
      // print(channels);
    }
  }
}
