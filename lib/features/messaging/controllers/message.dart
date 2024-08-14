import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message.g.dart';

@riverpod
class MessageController extends _$MessageController {
  @override
  Snowflake? build(Snowflake messageId) {
    return null;
  }

  void setInitialMessage(Snowflake messageId) {
    state = messageId;
  }
}
