import 'dart:typed_data';

import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'user_avatar.g.dart';

@riverpod
Future<Uint8List?> userAvatar(UserAvatarRef ref, User user) async {
  // String? hash = user.avatarHash;
  // // if (hash != null) {
  // //   var cached = await fetchMemberAvatarFromCache(member.avatarHash!);
  // //   if (cached != null) return cached;
  // // }
  // // if (user.avatar != null) return null;
  var iconUrl = user.avatar.url;
  var fetched = (await http.get(iconUrl)).bodyBytes;

  // await _cacheManager.putFile(
  //   http.get(iconUrl),
  //   member.avatarHash!,
  //   fetched,
  // );
  return fetched;
}
