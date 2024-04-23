import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/messaging/repositories/realtime_bind.dart';
import 'package:bonfire/features/messaging/repositories/realtime_messages.dart';
import 'package:bonfire/shared/models/member.dart';
import 'package:bonfire/shared/models/message.dart';
import 'package:bonfire/shared/utils/message.dart';
import 'package:flutter/widgets.dart';
import 'package:nyxx_self/nyxx.dart' as nyxx;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

part 'messages.g.dart';

/*
TODO: get messages when scrolling stop retrieving the correct data when
running the realtime listener
*/

@Riverpod(keepAlive: false)
class Messages extends _$Messages {
  AuthUser? user;
  bool loadingMessages = false;
  bool listenerRunning = false;
  nyxx.Message? oldestMessage;
  final _cacheManager = CacheManager(
    Config(
      'bonfire_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 10000,
    ),
  );
  Map<String, List<BonfireMessage>> channelMessagesMap = {};
  bool realtimeListernRunning = false;

  @override
  Future<List<BonfireMessage>> build() async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    var channelId = ref.watch(channelControllerProvider);

    if (channelId != null) {
      getMessages(authOutput, channelId);
      var fromCache = (await getChannelFromCache(channelId))!;
      return fromCache;
    }
    return [];
  }

  // Future<List<BonfireMessage>> fetchMessages(authOutput, channelId) async {
  //   List<BonfireMessage> fromCache = [];
  //   if (channelId != null) {
  //     getMessages(authOutput, channelId);
  //     fromCache = (await getChannelFromCache(channelId)) ?? [];
  //   }

  //   return fromCache;
  // }

  Future<void> runPreCacheRoutine(nyxx.Channel channel) async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    if (authOutput is AuthUser && channel is nyxx.TextChannel) {
      var channelFromCache = await getChannelFromCache(channel.id.value);
      if (channelFromCache == null) {
        getMessages(authOutput, channel.id.value, count: 20);
      }
    }
  }

  Future<void> getMessages(authOutput, int channelId,
      {int? before, int? count, int? guildId}) async {
    loadingMessages = true;
    if ((authOutput != null) &&
        (authOutput is AuthUser) &&
        (channelId != null)) {
      user = authOutput;
      var textChannel = await user!.client.channels
          .get(nyxx.Snowflake(channelId)) as nyxx.TextChannel;
      var beforeSnowflake = before != null ? nyxx.Snowflake(before) : null;
      var messages = await textChannel.messages
          .fetchMany(limit: count ?? 50, before: beforeSnowflake);
      List<Uint8List> memberAvatars = await Future.wait(
        messages.map((message) async {
          var avatar = await fetchMemberAvatar(message.author);
          if (avatar == null) {
            return message.author.avatar!.fetch();
          }
          return avatar;
        }),
      );
      List<BonfireMessage> channelMessages = [];
      for (int i = 0; i < messages.length; i++) {
        var message = messages[i];
        if (oldestMessage == null ||
            message.timestamp.isBefore(oldestMessage!.timestamp)) {
          oldestMessage = message;
        }
        var username = message.author.username;
        if (message.author is nyxx.User) {
          var user = message.author as nyxx.User;
          username = user.globalName ?? username;
        }
        var memberAvatar = memberAvatars[i];
        var newMessage = BonfireMessage(
          id: message.id.value,
          channelId: channelId,
          content: message.content,
          timestamp: message.timestamp,
          member: BonfireGuildMember(
            id: message.author.id.value,
            name: message.author.username,
            icon: Image.memory(memberAvatar),
            displayName: username,
            guildId: guildId ??
                ref.read(guildControllerProvider.notifier).currentGuild!.id,
          ),
        );
        channelMessages.add(newMessage);
      }
      if (before == null) {
        channelMessagesMap[channelId.toString()] = [];
      }
      if (channelMessages.isNotEmpty) {
        channelMessagesMap[channelId.toString()]!.addAll(channelMessages);

        if (before == null) {
          cacheMessages(channelMessages, channelId.toString());
        }
      }

      if (channelId == ref.read(channelControllerProvider)) {
        state = AsyncData(channelMessagesMap[channelId.toString()] ?? []);
      }
    }
    loadingMessages = false;
  }

  void processRealtimeMessages(List<BonfireMessage> messages) async {
    if (messages.isNotEmpty) {
      var message = messages.last;
      var channelId = message.channelId;
      if (channelId == ref.read(channelControllerProvider)) {
        // TODO: Only take the first message, and append :D
        // you could also take all of them and compare, to ensure we
        // didn't lose anything in a race condition

        if (channelMessagesMap[channelId.toString()] == null) {
          channelMessagesMap[channelId.toString()] = [];
        }
        channelMessagesMap[channelId.toString()]!.insert(0, message);
        state = AsyncData(channelMessagesMap[channelId.toString()] ?? []);
      }
    }
  }

  Future<List<BonfireMessage>?> getChannelFromCache(int channelId) async {
    var cacheData = await _cacheManager.getFileFromCache(channelId.toString());
    if (cacheData != null) {
      var cachedMessages =
          json.decode(utf8.decode(cacheData.file.readAsBytesSync()));
      var messagesFuture = (cachedMessages as List<dynamic>).map((e) async {
        var message = BonfireMessage.fromJson(e);
        var icon = (await fetchMemberAvatarFromCache(message.member.id));
        if (icon != null) message.member.icon = Image.memory(icon);

        return message;
      }).toList();

      print("got ${messagesFuture.length} messages from cache");

      return await Future.wait(messagesFuture);

      // var messages = await Future.wait(messagesFuture);
      // channelMessagesMap[channelId.toString()] = messages;
      // state = AsyncData(messages);
    }
    // no cache
    return null;
  }

  void fetchMoreMessages() {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    var channelId = ref.watch(channelControllerProvider);
    if (channelId != null) {
      getMessages(authOutput, channelId, before: oldestMessage!.id.value);
    }
  }

  Future<Uint8List?> fetchMemberAvatarFromCache(int userId) async {
    var cacheData = await _cacheManager.getFileFromCache(userId.toString());
    return cacheData?.file.readAsBytesSync();
  }

  Future<Uint8List> fetchMemberAvatar(nyxx.MessageAuthor user) async {
    var cached = await fetchMemberAvatarFromCache(user.id.value);
    if (cached != null) return cached;
    // if (user.avatar != null) return null;
    var fetched = await user.avatar!.fetch();
    await _cacheManager.putFile(
      user.id.toString(),
      fetched,
    );
    return fetched;
  }

  Future<void> cacheMessages(
      List<BonfireMessage> messages, String cacheKey) async {
    print("caching messages using key $cacheKey");
    var toCache = messages;
    if (toCache.length >= 21) {
      toCache = toCache.sublist(0, 20);
    }
    await _cacheManager.putFile(
      cacheKey,
      utf8.encode(json.encode(toCache.map((e) => e.toJson()).toList())),
    );
  }

  Future<bool> sendMessage(String message, {int? channelId}) async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    int? _channelId;
    if (channelId != null) {
      _channelId = channelId;
    } else {
      _channelId = ref.watch(channelControllerProvider);
    }
    if ((authOutput != null) &&
        (authOutput is AuthUser) &&
        (_channelId != null)) {
      user = authOutput;
      var textChannel = await user!.client.channels
          .get(nyxx.Snowflake(_channelId)) as nyxx.TextChannel;
      await textChannel.sendMessage(nyxx.MessageBuilder(
        content: message,
      ));
      return true;
    }
    return false;
  }
}
