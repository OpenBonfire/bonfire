import 'dart:typed_data';

import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'avatar.g.dart';

@Riverpod(keepAlive: true)
Future<Uint8List?> memberAvatar(Ref ref, Member member) async {
  // String? hash = member.user!.avatarHash;
  // if (hash != null) {
  //   var cached = await fetchMemberAvatarFromCache(hash);
  //   if (cached != null) return cached;
  // }
  var iconUrl = member.user?.avatar.url;
  if (iconUrl == null) return null;
  var fetched = (await http.get(iconUrl)).bodyBytes;
  return fetched;
}
