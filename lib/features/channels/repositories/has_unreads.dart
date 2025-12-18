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

    if (channel is GuildTextChannel) {
      lastMessageId = channel.lastMessageId;
    } else if (channel is GuildAnnouncementChannel) {
      lastMessageId = channel.lastMessageId;
    } else {
      return false;
    }

    // var readState = ref.watch(channelReadStateProvider(channel.id));

    // var lastReadMessage = readState?.lastMessage;
    var lastChannelMessageId = lastMessageId;

    // if (channelId == Snowflake.parse(1320481167102967869)) {
    //   print("Last Read Message = ${lastReadMessage?.id}");
    //   print("Last Channel Message = $lastChannelMessageId");
    //   print("Last viewed: ${readState?.lastViewed?.millisecondsSinceEpoch}");
    //   print(lastChannelMessageId!.timestamp.millisecondsSinceEpoch >
    //       readState!.lastViewed!.millisecondsSinceEpoch);

    //   print(lastChannelMessageId.timestamp.millisecondsSinceEpoch -
    //       readState.lastViewed!.millisecondsSinceEpoch);
    // }

    // if (lastChannelMessageId == null) return false;
    // if (lastReadMessage == null) return true;

    // return (readState!.lastViewed!.millisecondsSinceEpoch <
    //     lastChannelMessageId.timestamp.millisecondsSinceEpoch);

    return false;
  }
}
