import 'dart:async';

import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'typing.g.dart';

@riverpod
class Typing extends _$Typing {
  List<dynamic> users = <dynamic>[];
  Map<Snowflake, Timer> timers = {};

  @override
  Future<List<dynamic>> build(Snowflake channelId) async {
    var auth = ref.watch(authProvider.notifier).getAuth();
    if (auth is AuthUser) {
      auth.client.onTypingStart.listen((event) async {
        if (event.channelId == channelId) {
          if (timers.containsKey(event.member?.id ?? event.user.id)) {
            timers[event.member?.id ?? event.user.id]!.cancel();
            timers[event.member?.id ?? event.user.id] =
                Timer(const Duration(seconds: 10), () {
              users.remove(event.member!);
              state = AsyncValue.data(users);
            });
          } else {
            print("Channel ID; $channelId");
            users.add(event.member ?? await event.user.get());
            timers.putIfAbsent(event.member?.id ?? event.user.id, () {
              return Timer(const Duration(seconds: 10), () async {
                // don't like this, but it works
                // the user should technically be in the list
                users.remove(event.member ?? await event.user.get());
                state = AsyncValue.data(users);
              });
            });

            state = AsyncValue.data(users);
          }
        }
      });
    }

    return users;
  }

  void cancelTyping(Snowflake channelId, Snowflake memberId) {
    if (timers.containsKey(memberId)) {
      timers[memberId]!.cancel();
      users.removeWhere((element) => element.id == memberId);
      state = AsyncValue.data(users);
    }
  }
}
