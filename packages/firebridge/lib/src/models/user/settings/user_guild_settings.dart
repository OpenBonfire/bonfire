import 'package:firebridge/src/models/guild/guild.dart';
import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

class UserGuildSettings with ToStringHelper {
  final PartialGuild? partialGuild;
  final int version;
  final bool suppressRoles;
  final bool suppressEveryone;
  final int notifyHighlights;
  final bool muted;
  final bool muteScheduledEvents;
  final dynamic muteConfig;
  final bool mobilePush;
  final int messageNotifications;
  final bool hideMutedChannels;
  final int flags;
  final List<dynamic> channelOverrides;

  UserGuildSettings({
    required this.partialGuild,
    required this.version,
    required this.suppressRoles,
    required this.suppressEveryone,
    required this.notifyHighlights,
    required this.muted,
    required this.muteScheduledEvents,
    required this.muteConfig,
    required this.mobilePush,
    required this.messageNotifications,
    required this.hideMutedChannels,
    required this.flags,
    required this.channelOverrides,
  });
}
