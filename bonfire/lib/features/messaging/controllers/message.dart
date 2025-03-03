import 'package:bonfire/features/messaging/repositories/reactions.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message.g.dart';

@Riverpod(keepAlive: true)
class MessageController extends _$MessageController {
  @override
  Message? build(Snowflake messageId) {
    return null;
  }

  void setMessage(Message message) {
    if (message.reactions.isNotEmpty) {
      print("Reactions for ${message.id}: ${message.reactions}");
    }
    ref.read(messageReactionsProvider(message.id).notifier).setReactions(
          message.reactions,
        );
    state = message;
  }
}
