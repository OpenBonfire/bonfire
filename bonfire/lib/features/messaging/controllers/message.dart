import 'package:bonfire/features/authenticator/models/auth.dart';
import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/features/messaging/repositories/reactions.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message.g.dart';

@Riverpod(keepAlive: true)
class MessageController extends _$MessageController {
  NyxxGateway? client;
  @override
  Message? build(Snowflake messageId) {
    AuthResponse? user = ref.watch(authProvider.notifier).getAuth();
    if (user is! AuthUser) return null;

    client = user.client;

    return null;
  }

  void setMessage(Message message) {
    ref.read(messageReactionsProvider(message.id).notifier).setReactions(
          message.reactions,
        );
    state = message;
  }

  Future<void> editMessage(PartialMessage partialMessage) async {
    if (client == null) return;

    final message = await partialMessage.get();
    setMessage(message);
  }
}
