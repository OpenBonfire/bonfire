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
@Riverpod(keepAlive: true)
class Messages extends _$Messages {
  AuthUser? user;
  List<Message> loadedMessages = [];

  @override
  Future<List<Message>?> build(Snowflake channelId) async {
    if (loadedMessages.isNotEmpty) {
      return loadedMessages;
    }

    var auth = ref.watch(authProvider.notifier).getAuth();

    if (auth is! AuthUser) {
      print("bad auth!");
      return null;
    }

    print("Fetching messages for channel $channelId");

    user = auth;
    return await getMessages();
  }

  Timer lockTimer = Timer(Duration.zero, () {});

  Future<List<Message>?> getMessages({
    Snowflake? before,
    Snowflake? around,
    int? count,
    bool disableAck = false,
  }) async {
    if (user is AuthUser) {
      print("Getting messages");
      if (channelId == Snowflake.zero) return [];
      var channel = ref.watch(channelControllerProvider(channelId));
      if (channel == null) {
        print("Tried to request messages from a null channel.");
      }

      if (channel == null) return [];

      Guild? guild;
      Member? selfMember;

      if (channel is GuildChannel || channel is DmChannel) {
        if (channel is GuildChannel) {
          guild = ref.watch(guildControllerProvider(channel.guildId));
          if (guild == null) return [];
          selfMember = await guild.members.get(user!.client.user.id);
          var permissions = await channel.computePermissionsFor(selfMember);

          if (permissions.canReadMessageHistory == false) {
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
          .fetchMany(limit: count ?? 50, before: before, around: around);

      if (before == null && around == null) {
        loadedMessages = messages.toList();
      } else {
        loadedMessages.addAll(messages.toList());
      }

      if (before == null && (!disableAck == true)) {
        if (messages.isNotEmpty) {
          // await messages.first.manager.acknowledge(messages.first.id);
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

  Future<List<Message>> fetchMessages({
    Message? before,
    int? limit,
    Snowflake? around,
  }) async {
    Channel? channel = ref.watch(channelControllerProvider(channelId));
    if (channel == null) print("TRIED TO FETCH MESSAGES FOR NULL CHANNEL!");
    List<Message> messages = [];

    messages.addAll(loadedMessages);
    messages.addAll(await getMessages(
          before: before?.id,
          around: around,
          count: limit,
        ) ??
        []);

    if (before?.channel.id == channel!.id) {
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
    Channel? channel = ref.watch(channelControllerProvider(channelId));
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
      await textChannel.sendMessage(
        MessageBuilder(
          content: message,
          attachments: attachments,
          replyId: replyTo,
        ),
      );
      return true;
    }
    return false;
  }
}
