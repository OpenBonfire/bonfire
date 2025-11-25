import 'dart:typed_data';

import 'package:firebridge/firebridge.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'user_avatar.g.dart';

var _cacheManager = CacheManager(
  Config(
    'user_avatar_cache',
    //  maxNrOfCacheObjects: 1000,
  ),
);

@riverpod
Future<Uint8List?> userAvatar(Ref ref, User user) async {
  String? hash = user.avatarHash;
  if (hash != null) {
    var cached = await fetchMemberAvatarFromCache(hash);
    if (cached != null) return cached;
  }

  var iconUrl = user.avatar.url;
  var fetched = (await http.get(iconUrl)).bodyBytes;

  await _cacheManager.putFile(user.avatar.hash, fetched);
  return fetched;
}

Future<Uint8List?> fetchMemberAvatarFromCache(String hash) async {
  var file = await _cacheManager.getFileFromCache(hash);
  if (file == null) return null;
  return file.file.readAsBytes();
}
