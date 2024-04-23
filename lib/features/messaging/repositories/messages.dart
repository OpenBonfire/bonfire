import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
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
TODO: Fix state update when realtime message recieved.
*/

@Riverpod(keepAlive: false)
class Messages extends _$Messages {
  AuthUser? user;
  bool loadingMessages = false;
  nyxx.Message? oldestMessage;
  final _cacheManager = CacheManager(Config("bonfire_message_cache"));
  Map<String, List<BonfireMessage>> channelMessagesMap = {};
  bool realtimeListernRunning = false;
  var authOutput;
  var channelId;

  @override
  Future<List<BonfireMessage>?> build() async {
    authOutput = ref.watch(authProvider.notifier).getAuth();
    channelId = ref.watch(channelControllerProvider);
    // var realtimeProvider = ref.watch(realtimeMessagesProvider);

    // realtimeProvider.whenData((value) {
    //   processRealtimeMessages(value);
    // });
    print("building...");
  }

  Future<List<BonfireMessage>?> requestMessageBuildUpdate() async {
    if (channelId != null) {
      var channels = (await getChannelFromCache(channelId)) ?? [];
      // await getMessages(authOutput, channelId);
      // state = AsyncData((await getChannelFromCache(channelId)) ?? []);
      return channels;
    }
  }

  Future<void> getMessages(authOutput, channelId,
      {int? before, bool? forceDisableCache}) async {
    loadingMessages = true;
    if ((authOutput != null) &&
        (authOutput is AuthUser) &&
        (channelId != null)) {
      // load from cache if available
      if (before == null && forceDisableCache != true) {
        var loadedMessages = await getChannelFromCache(channelId);
        if (loadedMessages != null) {
          channelMessagesMap[channelId.toString()] = loadedMessages;

          state = AsyncData(loadedMessages);
          getMessages(authOutput, channelId, forceDisableCache: true);
        }
      }
    }

    user = authOutput;
    var textChannel = await user!.client.channels.get(nyxx.Snowflake(channelId))
        as nyxx.TextChannel;
    var beforeSnowflake = before != null ? nyxx.Snowflake(before) : null;
    var messages = await textChannel.messages
        .fetchMany(limit: 100, before: beforeSnowflake);
    List<Uint8List> memberAvatars = await Future.wait(
      messages.map((message) => fetchMemberAvatar(message.author)),
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
        channelId: message.channelId.value,
        content: message.content,
        timestamp: message.timestamp,
        member: BonfireGuildMember(
          id: message.author.id.value,
          name: message.author.username,
          icon: Image.memory(memberAvatar),
          displayName: username,
          guildId: ref.read(guildControllerProvider.notifier).currentGuild!.id,
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
        await _cacheManager.putFile(
          channelId.toString(),
          utf8.encode(
              json.encode(channelMessages.map((e) => e.toJson()).toList())),
        );
      }
    }
    // state = AsyncLoading();
    state = AsyncData(channelMessagesMap[channelId.toString()] ?? []);
    loadingMessages = false;
  }

  void processRealtimeMessages(List<BonfireMessage> messages) async {
    if (messages.isNotEmpty) {
      var channelIdProvider = ref.watch(channelControllerProvider);
      var message = messages.last;
      if (channelIdProvider != null) {
        var mapIdx = channelMessagesMap[message.member.guildId.toString()];

        if (mapIdx == null) {
          channelMessagesMap[message.member.guildId.toString()] = [message];
        } else {
          channelMessagesMap[message.member.guildId.toString()]!.add(message);
        }

        if (message.channelId == channelIdProvider) {
          state =
              AsyncData(channelMessagesMap[channelIdProvider.toString()] ?? []);
        }
      }
    }
  }

  void fetchMoreMessages() {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    var channelId = ref.watch(channelControllerProvider);
    getMessages(authOutput, channelId, before: oldestMessage!.id.value);
  }

  Future<List<BonfireMessage>?> getChannelFromCache(int channelId) async {
    var cacheData = await _cacheManager.getFileFromCache(channelId.toString());
    if (cacheData != null) {
      var cachedMessages =
          json.decode(utf8.decode(cacheData.file.readAsBytesSync()));
      var messagesFuture = (cachedMessages as List<dynamic>).map((e) async {
        var message = BonfireMessage.fromJson(e);
        message.member.icon = Image.memory(
            (await fetchMemberAvatarFromCache(message.member.id))!);

        return message;
      }).toList();

      return await Future.wait(messagesFuture);

      // var messages = await Future.wait(messagesFuture);
      // channelMessagesMap[channelId.toString()] = messages;
      // state = AsyncData(messages);
    }
    // no cache
    return null;
  }

  Future<Uint8List?> fetchMemberAvatarFromCache(int userId) async {
    var cacheData = await _cacheManager.getFileFromCache(userId.toString());
    return cacheData?.file.readAsBytesSync();
  }

  Future<Uint8List> fetchMemberAvatar(nyxx.MessageAuthor user) async {
    var cached = await fetchMemberAvatarFromCache(user.id.value);
    if (cached != null) return cached;
    var fetched = await user.avatar!.fetch();
    await _cacheManager.putFile(
      user.id.toString(),
      fetched,
    );
    return fetched;
  }

// Future<void> cacheMessages(
//     List<BonfireMessage> messages, String cacheKey) async {
//   await _cacheManager.putFile(
//     cacheKey,
//     utf8.encode(json.encode(messages.map((e) => e.toJson()).toList())),
//   );
// }

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
