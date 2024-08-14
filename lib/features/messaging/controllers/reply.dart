import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reply.g.dart';

class ReplyState {
  final Snowflake messageId;
  final bool shouldMention;

  ReplyState({
    required this.messageId,
    required this.shouldMention,
  });
}

@Riverpod(keepAlive: true)
class ReplyController extends _$ReplyController {
  @override
  ReplyState? build() {
    return null;
  }

  void setMessageReply(ReplyState? replyState) {
    state = replyState;
  }
}
