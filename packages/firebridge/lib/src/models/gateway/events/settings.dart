import 'package:firebridge/src/models/gateway/event.dart';
import 'package:firebridge/src/models/user/settings/user_guild_settings.dart';
import 'package:firebridge/src/models/user/settings/user_settings.dart';

/// Emitted when a user updates their settings.
class UserSettingsUpdateEvent extends DispatchEvent {
  final UserSettings userSettings;

  UserSettingsUpdateEvent({required super.gateway, required this.userSettings});
}

class UserGuildSettingsUpdateEvent extends DispatchEvent {
  final UserGuildSettings userGuildSettings;

  UserGuildSettingsUpdateEvent(
      {required super.gateway, required this.userGuildSettings});
}
