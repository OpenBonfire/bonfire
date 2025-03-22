import 'package:bonfire/features/authenticator/data/repositories/auth.dart';
import 'package:bonfire/features/authenticator/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile.g.dart';

@Riverpod(keepAlive: true)
class UserProfileController extends _$UserProfileController {
  @override
  Future<UserProfile?> build(Snowflake userId) async {
    var auth = ref.watch(authProvider.notifier).getAuth();
    if (auth is! AuthUser) return null;

    return await auth.client.users.fetchUserProfile(
      userId,
      withMutualFriends: true,
      withMutualFriendsCount: true,
      withMutualGuilds: true,
    );
  }
}
