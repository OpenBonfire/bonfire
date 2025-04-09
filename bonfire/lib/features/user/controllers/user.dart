import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.g.dart';

@Riverpod(keepAlive: true)
class UserController extends _$UserController {
  AuthUser? user;

  @override
  User? build(Snowflake userId) {
    return null;
  }

  void setUser(User user) {
    state = user;
  }
}
