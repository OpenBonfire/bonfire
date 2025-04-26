import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'self_user.g.dart';

/// Get the current user
@Riverpod(keepAlive: true)
class SelfUser extends _$SelfUser {
  AuthUser? user;

  @override
  Future<User?> build() async {
    var authOutput = ref.watch(authProvider);
    if (authOutput is AuthUser) {
      user = authOutput;

      return await user!.client.user.get();
    }
    return null;
  }
}
