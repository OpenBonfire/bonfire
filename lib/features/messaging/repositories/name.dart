import 'package:bonfire/features/guild/repositories/member.dart';
import 'package:bonfire/features/user/card/repositories/self_user.dart';
import 'package:collection/collection.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'name.g.dart';

@riverpod
Future<String?> messageAuthorName(MessageAuthorNameRef ref, Snowflake guildId,
    Channel channel, MessageAuthor author) async {
  Member? member = ref.watch(getMemberProvider(guildId, author.id)).valueOrNull;

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

  if (member == null) return null;

  return null;
}
