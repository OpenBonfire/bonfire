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

    runAsyncServerTask(authOutput, channelId);

    List<BonfireMessage> channelMessages = [];

    var cacheKey = channelId.toString();
    var cacheData = await _cacheManager.getFileFromCache(cacheKey);

    if (cacheData != null) {
      List<dynamic> cachedMessages =
          json.decode(utf8.decode(cacheData.file.readAsBytesSync()));
      for (var message in cachedMessages) {
        if (message['member']['id'] != null) {
          var pfp =
              await fetchMemberAvatarFromCache(message['member']['id'] as int);
          var newMessage = BonfireMessage.fromJson(message);
          newMessage.member.icon = Image.memory(pfp!);

          channelMessages.add(newMessage);
        } else {
          channelMessages.add(message);
        }
      }
    } else {
      print("cache is null!");
    }
    return channelMessages;
  }

  void runAsyncServerTask(authOutput, channelId) async {
    if ((authOutput != null) &&
        (authOutput is AuthUser) &&
        (channelId != null)) {
      user = authOutput;

      var textChannel = await user!.client.channels
          .fetch(nyxx.Snowflake(channelId)) as nyxx.TextChannel;

      var messages = await textChannel.messages.fetchMany(limit: 20);

      List<Uint8List> memberAvatars = await Future.wait(
        messages.map((message) => fetchMemberAvatar(message.author)),
      );

      List<BonfireMessage> channelMessages = [];
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
        _cacheMessages(channelMessages, channelId.toString());
      }
      await _cacheManager.putFile(
        channelId.toString(),
        utf8.encode(
            json.encode(channelMessages.map((e) => e.toJson()).toList())),
      );
      if (channelId == ref.read(channelControllerProvider)) {
        state = AsyncData(channelMessages);
      } else {
        // this is fine. We just don't want to return an invalid page state.
        print("channel switched before state return!");
      }
    }
  }

  Future<Uint8List?> fetchMemberAvatarFromCache(int userId) async {
    var cacheData = await _cacheManager.getFileFromCache(userId.toString());
    if (cacheData == null) return null;

    return cacheData.file.readAsBytesSync();
  }

  Future<Uint8List> fetchMemberAvatar(nyxx.MessageAuthor user) async {
    var cached = await fetchMemberAvatarFromCache(user.id.value);
    if (cached != null) return cached; // todo: check hash so the PFP can change

    var fetched = await user.avatar!.fetch();
    await _cacheManager.putFile(
      user.id.toString(),
      fetched,
    );
    return fetched;
  }

  Future<void> _cacheMessages(
      List<BonfireMessage> messages, String cacheKey) async {
    await _cacheManager.putFile(
      cacheKey,
      utf8.encode(json.encode(messages.map((e) => e.toJson()).toList())),
    );
  }
}
