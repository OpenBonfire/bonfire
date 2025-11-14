import 'package:bonfire/features/user/card/repositories/self_user.dart';
import 'package:collection/collection.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'name.g.dart';

@riverpod
Future<String?> messageAuthorName(
    Ref ref, Snowflake guildId, Channel channel, MessageAuthor author) async {
  String name = author.username;
  if (guildId == Snowflake.zero) {
    User? user = (channel as DmChannel).recipients.firstWhereOrNull(
          (element) => element.id == author.id,
        );

    if (user == null) {
      // assume it's ourselves
      User me = ref.read(selfUserProvider).valueOrNull!;
      name = me.globalName ?? name;
    } else {
      name = user.globalName ?? name;
    }
  }

  // if (member == null) return null;

  return name;
}
