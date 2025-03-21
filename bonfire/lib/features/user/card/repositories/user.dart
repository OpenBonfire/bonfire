import 'package:bonfire/features/authenticator/data/repositories/auth.dart';
import 'package:bonfire/features/authenticator/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.g.dart';

/// Get user by id
@riverpod
Future<User?> getUserFromId(GetUserFromIdRef ref, Snowflake userId) async {
  var user = ref.watch(authProvider.notifier).getAuth();
  if (user is AuthUser) {
    return await user.client.users.get(userId);
  }
  return null;
}
