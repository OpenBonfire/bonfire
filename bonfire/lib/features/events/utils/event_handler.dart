import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/channel_members.dart';
import 'package:bonfire/features/friends/controllers/relationships.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/guild/controllers/guilds.dart';
import 'package:bonfire/features/guild/controllers/role.dart';
import 'package:bonfire/features/guild/controllers/roles.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:bonfire/features/messaging/controllers/message.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/repositories/reactions.dart';
import 'package:bonfire/features/user/controllers/presence.dart';
import 'package:bonfire/features/user/controllers/user.dart';
import 'package:bonfire/features/voice/repositories/voice_members.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void handleEvents(Ref ref, NyxxGateway client) {
  client.onCacheUpdate.listen((entity) {
    switch (entity) {
      case Channel channel:
        ref
            .read(channelControllerProvider(channel.id).notifier)
            .setChannel(channel);
        break;

      case Guild guild:
        ref.read(guildControllerProvider(guild.id).notifier).setGuild(guild);
        // This existing alone scares me a bit. Should we be making all of firebridge riverpod?
        List<Snowflake> roleIds = [];
        for (var role in guild.roleList) {
          ref.read(roleControllerProvider(role.id).notifier).setRole(role);
          roleIds.add(role.id);
        }
        ref.read(rolesControllerProvider(guild.id).notifier).setRoles(roleIds);
        break;

      case Role _:
        // causes a "flash" when used in conjunction with setting the role ids
        // ref.read(roleControllerProvider(role.id).notifier).setRole(role);
        break;

      case User user:
        ref.read(userControllerProvider(user.id).notifier).setUser(user);
        break;

      case Message message:
        // print("Message update: ${message.id}");
        ref
            .read(messageControllerProvider(message.id).notifier)
            .setMessage(message);
        break;
    }
  });

  client.onReady.listen((event) {
    ref.read(guildsControllerProvider.notifier).setGuilds(event.guilds);

    ref
        .read(privateMessageHistoryProvider.notifier)
        .setMessageHistory(event.privateChannels);

    for (var channel in event.privateChannels) {
      ref
          .read(channelControllerProvider(channel.id).notifier)
          .setChannel(channel);
    }

    ref
        .read(guildFoldersProvider.notifier)
        .setGuildFolders(event.userSettings.guildFolders!);

    for (var readState in event.readStates) {
      ref
          .read(channelReadStateProvider(readState.channel.id).notifier)
          .setReadState(readState);
    }

    ref
        .read(selfStatusStateProvider.notifier)
        .setSelfStatus(event.userSettings.status!);

    ref
        .read(relationshipControllerProvider.notifier)
        .setRelationships(event.relationships);

    for (var presence in event.presences) {
      if (presence.user == null) continue;
      ref
          .read(presenceControllerProvider(presence.user!.id).notifier)
          .setPresence(presence);
    }

    if (event.userSettings.customStatus != null) {
      ref
          .read(customStatusStateProvider.notifier)
          .setCustomStatus(event.userSettings.customStatus!);
    }
  });

  client.onMessageUpdate.listen((event) {
    // ref
    //     .read(messageControllerProvider(event.message.id).notifier)
    //     .editMessage(event.oldMessage!);
  });

  client.onMessageCreate.listen((event) {
    // ref
    //     .read(messageControllerProvider(event.message.id).notifier)
    //     .setMessage(event.message);

    ref
        .read(messagesProvider(event.message.channelId).notifier)
        .processMessage(event.message);
  });

  client.onPresenceUpdate.listen((event) {
    ref
        .watch(presenceControllerProvider(event.user!.id).notifier)
        .setPresence(event);
  });

  client.onChannelUnread.listen((event) {
    for (var element in event.channelUnreadUpdates) {
      ref
          .read(channelReadStateProvider(element.readState.channel.id).notifier)
          .setReadState(element.readState);
    }
  });

  client.onMessageAck.listen((event) {
    ref
        .read(channelReadStateProvider(event.readState.channel.id).notifier)
        .setReadState(event.readState);
  });

  client.onVoiceStateUpdate.listen((event) {
    ref
        .read(voiceMembersProvider(event.state.guildId!).notifier)
        .processVoiceStateUpdate(event);
    ref
        .read(
          voiceMembersProvider(
            event.state.guildId!,
            channelId: event.state.channelId ?? event.oldState?.channelId,
          ).notifier,
        )
        .processVoiceStateUpdate(event);
  });

  client.onPresenceUpdate.listen((event) {
    if (event.status != null) {
      ref
          .read(UserStatusStateProvider(event.user!.id).notifier)
          .setUserStatus(event.status!);
    }
    if (event.activities != null) {
      ref
          .read(UserActivityStateProvider(event.user!.id).notifier)
          .setUserActivity(event.activities!);
    }
  });

  client.onGuildMemberListUpdate.listen((event) {
    ref
        .read(channelMembersProvider.notifier)
        .updateMemberList(event.operations, event.guildId, event.groups);
  });

  client.onRelationshipAdd.listen((event) {
    // TODO: handle shouldNotify
    ref
        .read(relationshipControllerProvider.notifier)
        .addRelationship(event.relationship);
  });

  client.onRelationshipRemove.listen((event) {
    ref
        .read(relationshipControllerProvider.notifier)
        .removeRelationship(event.id);
  });

  client.onMessageReactionAdd.listen((event) {
    ref
        .read(messageReactionsProvider(event.messageId).notifier)
        .addReaction(event.emoji, event.user, event.burstColors);
  });

  client.onMessageReactionRemove.listen((event) {
    ref
        .read(messageReactionsProvider(event.messageId).notifier)
        .removeReaction(event.emoji, event.user);
  });
}
