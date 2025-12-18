import 'dart:async';

import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'typing.g.dart';

@riverpod
class Typing extends _$Typing {
  List<dynamic> users = <dynamic>[];
  Map<Snowflake, Timer> timers = {};

  @override
  Future<List<dynamic>> build(Snowflake channelId) async {
    // var auth = ref.watch(clientControllerProvider);
    // if (auth is AuthUser) {
    //   auth.client.onTypingStart.listen((event) async {
    //     if (event.channelId == channelId) {
    //       var key = event.member?.id ?? event.user.id;
    //       if (timers.containsKey(key)) {
    //         timers[key]!.cancel();
    //         timers[key] = Timer(const Duration(seconds: 10), () async {
    //           // todo: this breaks in dms becaue there isn't a member
    //           users.remove(event.member ?? await event.user.get());
    //           state = AsyncValue.data(users);
    //         });
    //       } else {
    //         users.add(event.member ?? await event.user.get());
    //         timers.putIfAbsent(event.member?.id ?? event.user.id, () {
    //           return Timer(const Duration(seconds: 10), () async {
    //             // don't like this, but it works
    //             // the user should technically be in the list
    //             var id = event.member?.id ?? event.user.id;
    //             users.removeWhere((element) => element.id == id);
    //             timers.remove(id);
    //             state = AsyncValue.data(users);
    //           });
    //         });

    //         state = AsyncValue.data(users);
    //       }
    //     }
    //   });
    // }

    return users;
  }

  void cancelTyping(Snowflake channelId, Snowflake memberId) {
    if (timers.containsKey(memberId)) {
      timers[memberId]!.cancel();
      users.removeWhere((element) => element.id == memberId);
      timers.remove(memberId);
      state = AsyncValue.data(users);
    }
  }
}
