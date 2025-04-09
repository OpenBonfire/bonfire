import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'has_unreads.g.dart';

@Riverpod(keepAlive: true)
class HasUnreads extends _$HasUnreads {
  @override
  Future<bool> build(Snowflake channelId) async {
    Snowflake? lastMessageId;

    Channel? channel = ref.watch(channelControllerProvider(channelId));
    if (channel == null) {
      debugPrint("channel is null");
      return false;
    }

    // if (!(channel is GuildTextChannel || channel is GuildAnnouncementChannel)) {
    //   return false;
    // }

    // wait hold on why can't we just do pings?
    // debugPrint("has unreads ...");
    if (channel is GuildTextChannel) {
      lastMessageId = channel.lastMessageId;
    } else if (channel is GuildAnnouncementChannel) {
      lastMessageId = channel.lastMessageId;
    } else {
      return false;
    }

    var readState = ref.watch(channelReadStateProvider(channel.id));

    var lastReadMessage = readState?.lastMessage;
    var lastChannelMessageId = lastMessageId;

    // TODO: lastChannelMessageId is null *if* the last message is an application
    // command. I think it's a bug with application parsing (or something, unsure)
    // Validate to make sure that this is reproducable as I say it is.

    // update: I don't think that's true. Some channels with 1 message also don't work correctly.

    if (lastChannelMessageId == null) return false;
    if (lastReadMessage == null) return true;

    // debugPrint("computing using comparison");
    // debugPrint(lastChannelMessageId);
    // debugPrint(lastReadMessage.id);

    return (lastChannelMessageId > lastReadMessage.id) &&
        lastReadMessage.id != lastChannelMessageId;
  }
}
