import 'dart:async';
import 'dart:io';
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
  final CacheManager _cacheManager = DefaultCacheManager();

  @override
  Future<List<BonfireMessage>> build() async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    var channelId = ref.watch(channelControllerProvider);

    List<BonfireMessage> channelMessages = [];

    if ((authOutput != null) &
        (authOutput! is AuthUser) &
        (channelId != null)) {
      user = authOutput as AuthUser;

      print("start channel fetch!");
      var textChannel = await user!.client.channels
          .fetch(nyxx.Snowflake(channelId!)) as nyxx.GuildTextChannel;
      print("end channel fetch!");

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
      }
    } else {
      print("Not an auth user. This is probably very bad.");
    }
    state = AsyncData(channelMessages);
    return channelMessages;
  }

  Future<Uint8List> fetchMemberAvatar(nyxx.MessageAuthor user) async {
    final String avatarHash = user.avatar!.hash;
    FileInfo? cachedFileInfo =
        (await _cacheManager.getFileFromCache(avatarHash));
    if (cachedFileInfo != null) {
      // print("pulling from cache!");
      File cachedFile = cachedFileInfo.file;
      return await cachedFile.readAsBytes();
    } else {
      Uint8List avatarBytes = await user.avatar!.fetch();
      await _cacheManager.putFile(avatarHash, avatarBytes);
      return avatarBytes;
    }
  }
}
