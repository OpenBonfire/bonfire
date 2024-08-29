import 'dart:async';

import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/typing.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/messaging/controllers/message.dart';
import 'package:bonfire/features/messaging/controllers/reply.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages.g.dart';

/// Message provider for fetching messages from the Discord API
@riverpod
class Messages extends _$Messages {
  AuthUser? user;
  bool listenerRunning = false;
  DateTime lastFetchTime = DateTime.now();
  List<Message> loadedMessages = [];
  bool subscribed = false;

  @override
  Future<List<Message>?> build(Snowflake channelId) async {
    var auth = ref.watch(authProvider.notifier).getAuth();

    if (auth is! AuthUser) {
      print("bad auth!");
      return null;
    }

    user = auth;
    if (!subscribed) {
      _subscribeToMessages(auth, channelId);
      subscribed = true;
    }

    return await getMessages();
  }

  void _subscribeToMessages(AuthUser auth, Snowflake channelId) {
    // I don't know if I like this paradigm
    // Maybe I should make a better dispatcher from auth
    auth.client.onMessageCreate.listen((event) {
      if (event.message.channelId == channelId) {
        processMessage(event.message);
      }
    });
  }

  Timer lockTimer = Timer(Duration.zero, () {});

  Future<List<Message>?> getMessages({
    Snowflake? before,
    int? count,
    bool disableAck = false,
  }) async {
    if (user is AuthUser) {
      if (channelId == Snowflake.zero) return [];
      var channel = ref.watch(channelControllerProvider(channelId)).value;

      if (channel == null) return [];

      Guild? guild;
      Member? selfMember;

      if (channel is GuildChannel || channel is DmChannel) {
        if (channel is GuildChannel) {
          guild = ref.watch(guildControllerProvider(channel.guildId)).value;
          if (guild == null) return [];
          selfMember = await guild.members.get(user!.client.user.id);
          var permissions = await channel.computePermissionsFor(selfMember);

          if (permissions.canReadMessageHistory == false) {
            // I think there's still another permission we're missing here...
            // It ocassionally still errors
            print(
                "Error fetching messages in channel ${channel.id}, likely do not have access to channel bozo!");

            return [];
          }
        }

        if (channel is! TextChannel) {
          print(
              "Error fetching messages in channel ${channel.id}, not a text channel");

          return [];
        }
      }

      var messages = await (channel as TextChannel)
          .messages
          .fetchMany(limit: count ?? 50, before: before);

      if (before == null) {
        loadedMessages = messages.toList();
      } else {
        loadedMessages.addAll(messages.toList());
      }

      if (before == null && (!disableAck == true)) {
        if (messages.isNotEmpty) {
          await messages.first.manager.acknowledge(messages.first.id);
        }
      }

      for (var message in messages) {
        ref.read(messageControllerProvider(message.id).notifier).setMessage(
              message,
            );
      }

      return messages;
    } else {
      return null;
    }
  }

  Future<List<Message>> fetchMessages({Message? before, int? limit}) async {
    Channel channel =
        ref.watch(channelControllerProvider(channelId)).valueOrNull!;
    List<Message> messages = [];

    messages.addAll(loadedMessages);
    messages.addAll(await getMessages(
          before: before?.id,
          count: limit,
        ) ??
        []);

    if (before?.channel.id == channel.id) {
      state = AsyncValue.data(messages);
    }

    for (var message in messages) {
      ref.read(messageControllerProvider(message.id).notifier).setMessage(
            message,
          );
    }

    return messages;
  }

  void processMessage(Message message) async {
    Channel? channel =
        ref.watch(channelControllerProvider(channelId)).valueOrNull;
    if (channel == null) return;

    ref.read(messageControllerProvider(message.id).notifier).setMessage(
          message,
        );

    if (message.channel.id == channel.id) {
      ref
          .read(typingProvider(channel.id).notifier)
          .cancelTyping(channelId, message.author.id);
      loadedMessages.insert(0, message);

      state = AsyncValue.data(loadedMessages);
    }
  }

  Future<bool> sendMessage(
    Channel channel,
    String message, {
    List<AttachmentBuilder>? attachments,
  }) async {
    var authOutput = ref.watch(authProvider.notifier).getAuth();
    if (authOutput is AuthUser) {
      user = authOutput;
      var textChannel = channel as TextChannel;
      Snowflake? replyTo = ref.read(replyControllerProvider)?.messageId;
      bool? shouldMention = ref.read(replyControllerProvider)?.shouldMention;
      await textChannel.sendMessage(
        MessageBuilder(
          content: message,
          attachments: attachments,
          replyId: replyTo,
          // there's no mention option... might be a bot specific thing
          // mention: shouldMention,
        ),
      );
      return true;
    }
    return false;
  }
}
