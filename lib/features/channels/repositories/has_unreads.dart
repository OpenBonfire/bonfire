import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'has_unreads.g.dart';

@Riverpod(keepAlive: true)
class HasUnreads extends _$HasUnreads {
  @override
  Future<bool> build(Channel channel) async {
    Snowflake? lastMessageId;

    if (!(channel is GuildTextChannel || channel is GuildAnnouncementChannel)) {
      return false;
    }

    if (channel is GuildTextChannel) {
      lastMessageId = channel.lastMessageId;
    } else if (channel is GuildAnnouncementChannel) {
      lastMessageId = channel.lastMessageId;
    } else {
      return false;
    }

    var readState = ref.watch(channelReadStateProvider);
    var lastReadMessage = readState?[channel.id]?.lastPartialMessage;
    var lastChannelMessageId = lastMessageId;

    if (lastChannelMessageId == null) return false;
    if (lastReadMessage == null) return true;

    return lastChannelMessageId != lastReadMessage.id;
  }
}
