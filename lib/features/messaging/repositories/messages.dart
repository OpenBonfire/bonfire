import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
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
    await getMessages(authOutput, channelId);
    return channelMessagesMap[channelId.toString()] ?? [];
  }

  Future<void> getMessages(authOutput, channelId, {int? before}) async {
    loadingMessages = true;
    if ((authOutput != null) &&
        (authOutput is AuthUser) &&
        (channelId != null)) {
      user = authOutput;
      var textChannel = await user!.client.channels
          .get(nyxx.Snowflake(channelId)) as nyxx.TextChannel;
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
          content: message.content,
          timestamp: message.timestamp,
          member: BonfireGuildMember(
            id: message.author.id.value,
            name: message.author.username,
            icon: Image.memory(memberAvatar),
            displayName: username,
            guildId:
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
          await _cacheManager.putFile(
            channelId.toString(),
            utf8.encode(
                json.encode(channelMessages.map((e) => e.toJson()).toList())),
          );
        }
      }
      state = AsyncLoading();
      state = AsyncData(channelMessagesMap[channelId.toString()] ?? []);
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

  Future<void> _cacheMessages(
      List<BonfireMessage> messages, String cacheKey) async {
    await _cacheManager.putFile(
      cacheKey,
      utf8.encode(json.encode(messages.map((e) => e.toJson()).toList())),
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
