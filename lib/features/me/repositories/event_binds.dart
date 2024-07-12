import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_binds.g.dart';

@riverpod
Future<void> settingsEventBindings(SettingsEventBindingsRef ref) async {
  var auth = ref.watch(authProvider.notifier).getAuth();
  // if (auth is AuthUser) {
  //   auth.client.onChannelUnread
  // }
}
