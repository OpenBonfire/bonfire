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

    var readState = ref.watch(channelReadStateProvider(channel.id));
    var lastReadMessage = readState?.lastMessage;
    var lastChannelMessageId = lastMessageId;

    // TODO: lastChannelMessageId is null *if* the last message is an application
    // command. I think it's a bug with application parsing (or something, unsure)
    // Validate to make sure that this is reproducable as I say it is.

    if (lastChannelMessageId == null) return false;
    if (lastReadMessage == null) return true;

    return lastChannelMessageId > lastReadMessage.id ||
        lastChannelMessageId != lastReadMessage.id;
  }
}
