import 'dart:typed_data';

import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:http/http.dart' as http;

part 'avatar.g.dart';

@riverpod
Future<Uint8List?> messageAuthorAvatar(
    MessageAuthorAvatarRef ref, MessageAuthor member) async {
  String? hash = member.avatarHash;
  // if (hash != null) {
  //   var cached = await fetchMemberAvatarFromCache(member.avatarHash!);
  //   if (cached != null) return cached;
  // }
  // if (user.avatar != null) return null;
  var iconUrl = member.avatar?.url;
  if (iconUrl == null) return null;
  var fetched = (await http.get(iconUrl)).bodyBytes;

  // await _cacheManager.putFile(
  //   http.get(iconUrl),
  //   member.avatarHash!,
  //   fetched,
  // );
  return fetched;
}
