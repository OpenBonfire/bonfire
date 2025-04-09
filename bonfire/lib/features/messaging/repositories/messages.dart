import 'dart:async';

import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/channel_repo.dart';
import 'package:bonfire/features/channels/repositories/typing.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/guild/controllers/role.dart';
import 'package:bonfire/features/guild/controllers/roles.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/features/messaging/controllers/message.dart';
import 'package:bonfire/features/messaging/controllers/reply.dart';
import 'package:firebridge_extensions/firebridge_extensions.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages.g.dart';

/// Message provider for fetching messages from the Discord API
@Riverpod(keepAlive: true)
class Messages extends _$Messages {
  AuthUser? user;
  List<Message> loadedMessages = [];

  @override
  Future<List<Message>?> build(Snowflake channelId) async {
    // I want it to reload if we re-auth; this might not work
    ref.watch(authProvider);

    if (loadedMessages.isNotEmpty) {
      return loadedMessages;
    }

    var auth = ref.watch(authProvider.notifier).getAuth();

    if (auth is! AuthUser) {
      debugPrint("bad auth!");
      return null;
    }

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
      if (channelId == Snowflake.zero) return [];
      var channel = ref.watch(channelControllerProvider(channelId));

      // print(channelId);
      if (channel == null) {
        debugPrint("Tried to request messages from a null channel.");
      } else {}

      if (channel == null) return [];

      if (channel is GuildChannel) {
        Member? selfMember;
        Guild? guild = ref.watch(guildControllerProvider((channel).guildId))!;
        List<Snowflake> roleIds =
            ref.watch(rolesControllerProvider(channel.guildId))!;
        List<Role> roles = [];
        for (Snowflake roleId in roleIds) {
          Role role = ref.watch(roleControllerProvider(roleId))!;
          roles.add(role);
        }

        selfMember = await guild.members.get(user!.client.user.id);
        var permissions =
            await channel.computePermissionsForMemberWithGuildAndRoles(
                selfMember, guild, roles);

        if (permissions.canReadMessageHistory == false) {
          debugPrint(
              "Error fetching messages in channel ${channel.id}, likely do not have access to channel bozo!");
          return [];
        }
      }

      if (channel is! TextChannel) {
        debugPrint(
            "Error fetching messages in channel ${channel.id}, not a text channel");
        return [];
      }

      var messages = await channel.messages
          .fetchMany(limit: count ?? 50, before: before, around: around);

      if (before == null && around == null) {
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
      // print("got messages for ${channel.runtimeType}");
      // print(messages);
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
    if (channel == null)
      debugPrint("TRIED TO FETCH MESSAGES FOR NULL CHANNEL!");
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

    ReadState? currentReadState =
        ref.read(channelReadStateProvider(message.channelId));

    int mentionCount = currentReadState?.mentionCount ?? 0;
    bool mentionsSelf = false;
    for (var mention in message.mentions) {
      if (mention.id == user!.client.user.id) {
        mentionsSelf = true;
        break;
      }
    }

    if ((mentionsSelf || channel is DmChannel || channel is GroupDmChannel) &&
        message.author.id != user!.client.user.id) {
      mentionCount++;
    }

    ref.read(channelReadStateProvider(message.channelId).notifier).setReadState(
          ReadState(
            channel: message.channel,
            lastMessage: message,
            lastPinTimestamp: currentReadState?.lastPinTimestamp,
            mentionCount: mentionCount,
            lastViewed: currentReadState?.lastViewed,
          ),
        );

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
