import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_messages.g.dart';

/// Message provider for fetching user messages from the Discord API
@Riverpod(keepAlive: true)
class UserMessages extends _$UserMessages {
  AuthUser? user;

  @override
  Future<void> build() async {
    var authOutput = ref.watch(clientControllerProvider);
    if (authOutput is AuthUser) {
      user = authOutput;
      // debugPrint("LISTING CHANNELS!");

      // try {
      //   var channels = await user!.client.channels.listDmChannels();
      //   debugPrint("GOT CHANNNELS");
      //   debugPrint(channels);
      // } catch (e) {
      //   debugPrint("ERROR GETTING CHANNELS");
      //   debugPrint(e);
      // }

      // debugPrint("GOT CHANNNELS1");
      // debugPrint(channels);
    }
  }
}
