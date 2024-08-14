import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reply.g.dart';

@Riverpod(keepAlive: true)
class ReplyController extends _$ReplyController {
  @override
  Snowflake? build() {
    return null;
  }

  void setMessageReply(Snowflake? messageId) {
    state = messageId;
  }
}
