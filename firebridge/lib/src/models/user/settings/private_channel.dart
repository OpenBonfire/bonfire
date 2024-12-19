import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

/// Private channel. Used for direct messaging.
class PrivateChannel with ToStringHelper {
  List<dynamic>? safetyWarnings;
  bool? isSpam;
  Snowflake? lastMessageId;
  int type;
  List<User> recipients;
  Snowflake id;
  int flags;

  PrivateChannel({
    this.safetyWarnings,
    this.isSpam,
    this.lastMessageId,
    required this.type,
    required this.recipients,
    required this.id,
    required this.flags,
  });
}
