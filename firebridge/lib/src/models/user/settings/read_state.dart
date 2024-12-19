import 'package:firebridge/src/models/channel/channel.dart';
import 'package:firebridge/src/models/message/message.dart';
import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

class ReadState with ToStringHelper {
  PartialChannel channel;
  int? flags;
  int? mentionCount;
  PartialMessage? lastMessage;
  DateTime? lastViewed;
  DateTime? lastPinTimestamp;

  ReadState({
    required this.channel,
    this.flags,
    this.mentionCount,
    this.lastMessage,
    this.lastViewed,
    this.lastPinTimestamp,
  });
}
