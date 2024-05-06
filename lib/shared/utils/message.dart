import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:nyxx_self/nyxx.dart' as nyxx;
import 'package:bonfire/shared/models/member.dart';
import 'package:bonfire/shared/models/message.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MessageConverter {
  static Future<BonfireMessage> convert(
      nyxx.Message message, int guildId) async {
    var username = message.author.username;
    if (message.author is nyxx.User) {
      var user = message.author as nyxx.User;
      username = user.globalName ?? username;
    }

    var memberAvatar = await fetchMemberAvatar(message.author);
    var bonfireMessage = BonfireMessage(
      id: message.id.value,
      channelId: message.channelId.value,
      content: message.content,
      timestamp: message.timestamp,
      member: BonfireGuildMember(
          id: message.author.id.value,
          name: message.author.username,
          iconUrl: message.author.avatar!.url.toString(),
          icon: Image.memory(memberAvatar),
          displayName: username,
          guildId: guildId),
    );
    return bonfireMessage;
  }

  static Future<Uint8List> fetchMemberAvatar(nyxx.MessageAuthor user) async {
    String cacheKey = user.avatarHash ?? user.id.toString();

    var cacheManager = CacheManager(Config('avatar_cache'));
    var cacheData = await cacheManager.getFileFromCache(cacheKey);

    if (cacheData != null) {
      return cacheData.file.readAsBytesSync();
    } else {
      var fetchedAvatar = await user.avatar!.fetch();
      await cacheManager.putFile(cacheKey, fetchedAvatar);

      return fetchedAvatar;
    }
  }
}
