import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

part 'messages.g.dart';

/// Message provider for fetching messages from the Discord API
@Riverpod(keepAlive: true)
class Messages extends _$Messages {
  AuthUser? user;
  bool listenerRunning = false;
  DateTime lastFetchTime = DateTime.now();
  Map<Snowflake, List<Message>> messageCache = {};

  final _cacheManager = CacheManager(
    Config(
      'messages',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 10000,
    ),
  );

  bool realtimeListernRunning = false;

  @override
  Future<List<Message>> build(Snowflake guildId, Snowflake channelId) async {
    var auth = ref.watch(authProvider.notifier).getAuth();

    if (auth is! AuthUser) {
      print("bad auth!");
    }

    user = auth as AuthUser;
    var messages = await getMessages();
    return messages;
  }

  Timer lockTimer = Timer(Duration.zero, () {});

  Future<List<Message>> getMessages({
    Channel? channelOverride,
    Snowflake? before,
    int? count,
  }) async {
    if (user is AuthUser) {
      var channel =
          ref.watch(channelControllerProvider(channelId)).value as GuildChannel;

      var guild = ref.watch(guildControllerProvider(guildId)).value!;

      var selfMember = await guild.members.get(user!.client.user.id);
      var permissions = await channel.computePermissionsFor(selfMember);

      if (permissions.canReadMessageHistory == false) {
        // I think there's still another permission we're missing here...
        // It ocassionally still errors
        print(
            "Error fetching messages in channel ${channel.id}, likely do not have access to channel bozo!");

        return [];
      }

      if (channel is! TextChannel) {
        print(
            "Error fetching messages in channel ${channel.id}, not a text channel");

        return [];
      }

      var messages = await (channel as TextChannel)
          .messages
          .fetchMany(limit: count ?? 50, before: before);

      if (before == null) {
        messageCache[channel.id] = messages.toList();
      } else {
        messageCache[channel.id]!.addAll(messages);
      }

      return messages;
    } else {
      return [];
    }
  }

  void processRealtimeMessages(List<Message> messages) async {
    // Ensure we have a valid channel to work with
    Channel? channel =
        ref.watch(channelControllerProvider(channelId)).valueOrNull;

    if (channel == null || messages.isEmpty) {
      return;
    }

    // If the channel has a way to update its state or notify listeners, do it here
    // Since there's no explicit state management mentioned, we print the new messages for debugging
    List<Message> channelMessages = messageCache[channel.id] ?? [];

    Message message = messages.last;
    if (message.channel.id == channel.id) {
      channelMessages.insert(0, message);
      state = AsyncValue.data(channelMessages);
    }
  }

  Future<List<Message>?> getChannelFromCache(Channel channel) async {
    var cacheData = await _cacheManager.getFileFromCache(channel.id.toString());
    if (cacheData != null) {
      var cachedMessages =
          json.decode(utf8.decode(cacheData.file.readAsBytesSync()));
      var messagesFuture = (cachedMessages as List<dynamic>).map((e) async {
        var message = channel.manager.parse(e) as Message;

        return message;
      }).toList();
      return await Future.wait(messagesFuture);
    }
    // no cache
    return null;
  }

  /// Returns the age of the message entry in the cache from [channel]
  Future<Duration?> getAgeOfMessageEntry(int channel) async {
    var cacheData = await _cacheManager.getFileFromCache(channel.toString());
    if (cacheData == null) return null;

    var age = cacheData.file.lastModifiedSync().difference(DateTime.now());
    return age;
  }

  Future<List<Message>> fetchMessagesBefore(Message message) async {
    // var delta = DateTime.now().difference(lastFetchTime);
    // if (delta.inMilliseconds < 500) return;
    // lastFetchTime = DateTime.now();
    Channel channel =
        ref.watch(channelControllerProvider(channelId)).valueOrNull!;
    List<Message> messages = [];

    messages.addAll(messageCache[channel.id]!);
    messages.addAll(await getMessages(before: message.id));

    if (message.channel.id == channel.id) {
      state = AsyncValue.data(messages);
    }

    return messages;
  }

  Future<Uint8List?> fetchMemberAvatarFromCache(String hash) async {
    var cacheData = await _cacheManager.getFileFromCache(hash);
    return cacheData?.file.readAsBytesSync();
  }

  Future<Uint8List?> fetchMessageAuthorAvatar(MessageAuthor member) async {
    String? hash = member.avatarHash;
    if (hash != null) {
      var cached = await fetchMemberAvatarFromCache(member.avatarHash!);
      if (cached != null) return cached;
    }
    // if (user.avatar != null) return null;
    var iconUrl = member.avatar?.url;
    if (iconUrl == null) return null;
    var fetched = (await http.get(iconUrl)).bodyBytes;

    await _cacheManager.putFile(
      member.avatarHash!,
      fetched,
    );
    return fetched;
  }

  Future<Uint8List?> fetchMemberAvatar(Member member) async {
    String? hash = member.user!.avatarHash;
    // if (hash != null) {
    //   var cached = await fetchMemberAvatarFromCache(hash);
    //   if (cached != null) return cached;
    // }
    var iconUrl = member.user?.avatar.url;
    if (iconUrl == null) return null;
    var fetched = (await http.get(iconUrl)).bodyBytes;

    if (hash != null) {
      await _cacheManager.putFile(
        hash,
        fetched,
      );
    }
    return fetched;
  }

  Future<void> cacheMessages(List<Message> messages, String cacheKey) async {
    // print("caching messages using key $cacheKey");
    // var toCache = messages;
    // if (toCache.length >= 21) {
    //   toCache = toCache.sublist(0, 20);
    // }
    // await _cacheManager.putFile(
    //   cacheKey,
    //   utf8.encode(json.encode(toCache.map((e) => e.toJson()).toList())),
    // );
  }

  Future<bool> sendMessage(Channel channel, String message) async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    if (authOutput is AuthUser) {
      user = authOutput;
      var textChannel = channel as TextChannel;
      await textChannel.sendMessage(MessageBuilder(
        content: message,
      ));
      return true;
    }
    return false;
  }
}
