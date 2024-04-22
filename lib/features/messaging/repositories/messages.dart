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
  bool loadingMessages = false;
  nyxx.Message? oldestMessage;

  final _cacheManager = CacheManager(
    Config(
      'bonfire_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 10000,
    ),
  );

  Map<String, List<BonfireMessage>> channelMessagesMap = {};

  @override
  Future<List<BonfireMessage>> build() async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    var channelId = ref.watch(channelControllerProvider);

    getMessages(authOutput, channelId);

    List<BonfireMessage> channelMessages =
        channelMessagesMap[channelId.toString()] ?? [];
    print("sending cached");
    return channelMessages;
  }

  void getMessages(authOutput, channelId, {int? before}) async {
    loadingMessages = true;
    if ((authOutput != null) &&
        (authOutput is AuthUser) &&
        (channelId != null)) {
      user = authOutput;

      var textChannel = await user!.client.channels
          .fetch(nyxx.Snowflake(channelId)) as nyxx.TextChannel;

      var beforeSnowflake = before != null ? nyxx.Snowflake(before) : null;

      var messages = await textChannel.messages
          .fetchMany(limit: 100, before: beforeSnowflake);

      List<Uint8List> memberAvatars = await Future.wait(
        messages.map((message) => fetchMemberAvatar(message.author)),
      );

      List<BonfireMessage> channelMessages = [];
      for (int i = 0; i < messages.length; i++) {
        var message = messages[i];
        // check & set oldest message
        if (oldestMessage == null) {
          oldestMessage = message;
        } else if (message.timestamp.isBefore(oldestMessage!.timestamp)) {
          oldestMessage = message;
        }

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
      }

      if (channelMessagesMap[channelId.toString()] != null) {
        channelMessagesMap[channelId.toString()]!.addAll(channelMessages);
      } else {
        channelMessagesMap[channelId.toString()] = channelMessages;
      }

      await _cacheManager.putFile(
        channelId.toString(),
        utf8.encode(
            json.encode(channelMessages.map((e) => e.toJson()).toList())),
      );

      if (channelId == ref.read(channelControllerProvider)) {
        var newChannels = channelMessagesMap[channelId.toString()]!;

        var max = newChannels.length;
        var range1 = newChannels.getRange(0, (max < 49) ? max : 49).toList();
        var range2 = newChannels.getRange(50, newChannels.length).toList();

        state = AsyncData(range1);
        await Future.delayed(const Duration(milliseconds: 100));
        range1.addAll(range2);
        state = AsyncData(range1);
      } else {
        // this is fine. We just don't want to return an invalid page state.
        print("channel switched before state return!");
      }
    }
    loadingMessages = false;
  }

  void fetchMoreMessages() {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    var channelId = ref.watch(channelControllerProvider);

    getMessages(authOutput, channelId, before: oldestMessage!.id.value);
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
