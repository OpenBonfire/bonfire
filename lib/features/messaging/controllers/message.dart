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
    state = message;
  }
}
