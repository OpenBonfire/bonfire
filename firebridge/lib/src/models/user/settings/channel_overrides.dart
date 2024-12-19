import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

class ChannelOverrides with ToStringHelper {
  bool muted;
  dynamic muteConfig;
  int messageNotifications;
  int flags;
  bool collapsed;
  String channelId;

  ChannelOverrides({
    required this.muted,
    required this.muteConfig,
    required this.messageNotifications,
    required this.flags,
    required this.collapsed,
    required this.channelId,
  });
}
