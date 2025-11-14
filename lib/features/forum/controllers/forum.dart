import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forum.g.dart';

@Riverpod(keepAlive: true)
class ThreadChannel extends _$ThreadChannel {
  @override
  Channel? build(Snowflake channelId) {
    return null;
  }

  void setThreadChannel(Channel publicThread) {
    state = publicThread;
  }
}

@Riverpod(keepAlive: true)
class FirstMessage extends _$FirstMessage {
  @override
  Message? build(Snowflake channelId) {
    return null;
  }

  void setFirstMessage(Message firstMessage) {
    state = firstMessage;
  }
}
