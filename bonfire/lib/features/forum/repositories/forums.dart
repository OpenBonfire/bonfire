import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forums.g.dart';

/// Fetches a forum channel from the [channelId].
@Riverpod(keepAlive: true)
class Forums extends _$Forums {
  @override
  Future<ForumChannel?> build(Snowflake channelId) async {
    var auth = ref.watch(authProvider.notifier).getAuth();

    if (auth is AuthUser) {
      Channel channel = await auth.client.channels.get(channelId);

      if (channel is ForumChannel) {
        return channel;
      } else {
        debugPrint('Channel is not a forum channel');
      }
    }

    return null;
  }
}
