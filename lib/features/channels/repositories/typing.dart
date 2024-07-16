import 'dart:async';

import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'typing.g.dart';

@riverpod
class Typing extends _$Typing {
  List<Member> users = <Member>[];
  Map<Snowflake, Timer> timers = {};

  @override
  Future<List<Member>> build(Snowflake channelId) async {
    var auth = ref.watch(authProvider.notifier).getAuth();
    if (auth is AuthUser) {
      auth.client.onTypingStart.listen((event) async {
        event.member;
        if (event.channelId == channelId) {
          if (timers.containsKey(event.member!.id)) {
            timers[event.member!.id]!.cancel();
            timers[event.member!.id] = Timer(const Duration(seconds: 10), () {
              users.remove(event.member!);
              state = AsyncValue.data(users);
            });
          } else {
            users.add(event.member!);
            timers.putIfAbsent(event.member!.id, () {
              return Timer(const Duration(seconds: 10), () {
                users.remove(event.member!);
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
