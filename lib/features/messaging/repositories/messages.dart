import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/shared/models/channel.dart';
import 'package:bonfire/shared/models/guild.dart';
import 'package:bonfire/shared/models/member.dart';
import 'package:bonfire/shared/models/message.dart';
import 'package:flutter/widgets.dart';
import 'package:nyxx_self/nyxx.dart' as nyxx;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

part 'messages.g.dart';

@Riverpod(keepAlive: false)
class Messages extends _$Messages {
  AuthUser? user;
  final _cacheManager = CacheManager(
    Config(
      'bonfire_cache',
      // stalePeriod: const Duration(days: 7),
      // maxNrOfCacheObjects: 100,
    ),
  );

  @override
  Future<List<BonfireMessage>> build() async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    var channelId = ref.watch(channelControllerProvider);

    List<BonfireMessage> channelMessages = [];

    // PULL FROM CACHE
    var cacheKey = channelId.toString();
    var cacheData = await _cacheManager.getFileFromCache(cacheKey);
    print("cacheKey: $cacheKey");
    if (cacheData != null) {
      print("CacheData: ");
      print(cacheData.file.absolute.path);
      print("doing decode on cache...");
      // print(utf8.decode(cacheData.file.readAsBytesSync()));
      List<dynamic> cachedMessages =
          json.decode(utf8.decode(cacheData.file.readAsBytesSync()));
      for (var message in cachedMessages) {
        channelMessages.add(BonfireMessage.fromJson(message));
      }
      return channelMessages;
    } else {
      print("cache is null!");
    }

    if ((authOutput != null) &&
        (authOutput is AuthUser) &&
        (channelId != null)) {
      user = authOutput;

      var textChannel = await user!.client.channels
          .fetch(nyxx.Snowflake(channelId)) as nyxx.GuildTextChannel;

      var messages = await textChannel.messages.fetchMany(limit: 100);

      List<Uint8List> memberAvatars = await Future.wait(
        messages.map((message) => fetchMemberAvatar(message.author)),
      );

      for (int i = 0; i < messages.length; i++) {
        var message = messages[i];
        var memberAvatar = memberAvatars[i];
        var newMessage = BonfireMessage(
          id: message.id.value,
          content: message.content,
          timestamp: message.timestamp,
          member: BonfireMember(
            id: message.author.id.value,
            name: message.author.username,
            icon: Image.memory(memberAvatar),
          ),
        );
        channelMessages.add(newMessage);
        _cacheMessages(channelMessages, cacheKey);
      }

      print("saving to key: ");
      print(cacheKey);

      var file = await _cacheManager.putFile(
        cacheKey,
        utf8.encode(
            json.encode(channelMessages.map((e) => e.toJson()).toList())),
      );
      print(file.path);
    } else {
      print("Not an auth user. This is probably very bad.");
    }
    print("setting state");
    state = AsyncData(channelMessages);
    return channelMessages;
  }

  Future<Uint8List> fetchMemberAvatar(nyxx.MessageAuthor user) async {
    return await user.avatar!.fetch();
  }

  Future<void> _cacheMessages(
      List<BonfireMessage> messages, String cacheKey) async {
    await _cacheManager.putFile(
      cacheKey,
      utf8.encode(json.encode(messages.map((e) => e.toJson()).toList())),
    );
  }
}
