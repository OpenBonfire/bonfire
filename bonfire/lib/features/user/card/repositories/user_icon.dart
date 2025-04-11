import 'dart:typed_data';

import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_icon.g.dart';

/// Get the icon of a given user by id
@Riverpod(keepAlive: true)
class UserIcon extends _$UserIcon {
  AuthUser? user;

  @override
  Future<Uint8List?> build(Snowflake userId) async {
    var authOutput = ref.watch(authProvider);
    if (authOutput is AuthUser) {
      user = authOutput;

      return await (await user!.client.users[userId].get()).avatar.fetch();
    }
    return null;
  }
}
