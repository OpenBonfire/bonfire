import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unread_listener.g.dart';

@riverpod
class UnreadListener extends _$UnreadListener {
  @override
  bool build(Snowflake channelId) {
    var auth = ref.watch(authProvider.notifier).getAuth();
    if (auth is AuthUser) {
      auth.client.onChannelUnread.listen((event) async {
        if (event.channelUnreadUpdates.first.id == channelId) {
          var channelObj = await auth
              .client.channels[event.channelUnreadUpdates.first.id]
              .get() as GuildChannel;
          state = true;
          print(channelObj.name);
        }
      });
    }
    return false;
  }
}
