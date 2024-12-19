import 'package:firebridge/src/models/presence.dart';
import 'package:firebridge/src/models/user/settings/custom_status.dart';
import 'package:firebridge/src/models/user/settings/guild_folder.dart';
import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

class UserSettings with ToStringHelper {
  bool? detectPlatformAccounts;
  int? animateStickers;
  bool? inlineAttachmentMedia;
  UserStatus? status;
  bool? messageDisplayCompact;
  bool? viewNsfwGuilds;
  int? timezoneOffset;
  bool? enableTtsCommand;
  bool? disableGamesTab;
  bool? streamNotificationsEnabled;
  bool? animateEmoji;
  List<GuildFolder>? guildFolders;
  CustomStatus? customStatus;

  UserSettings({
    this.detectPlatformAccounts,
    this.animateStickers,
    this.inlineAttachmentMedia,
    this.status,
    this.messageDisplayCompact,
    this.viewNsfwGuilds,
    this.timezoneOffset,
    this.enableTtsCommand,
    this.disableGamesTab,
    this.streamNotificationsEnabled,
    this.animateEmoji,
    this.guildFolders,
    this.customStatus,
  });
}
