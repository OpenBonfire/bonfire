import 'package:discord_api/discord_api.dart';
import 'package:riverpod/riverpod.dart';

final discordAuthProvider = StateNotifierProvider<DiscordAuthNotifier, DiscordClient?>(
  (ref) => DiscordAuthNotifier(),
);

class DiscordAuthNotifier extends StateNotifier<DiscordClient?> {
  DiscordAuthNotifier() : super(null);

  void setObj(DiscordClient? obj) {
    state = obj;
  }
}