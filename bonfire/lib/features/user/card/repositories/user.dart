import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.g.dart';

/// Get user by id
@riverpod
Future<User?> getUserFromId(Ref ref, Snowflake userId) async {
  var user = ref.watch(authProvider);
  if (user is AuthUser) {
    return await user.client.users.get(userId);
  }
  return null;
}
