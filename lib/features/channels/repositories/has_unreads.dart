import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';

part 'has_unreads.g.dart';

@Riverpod(keepAlive: true)
class HasUnreads extends _$HasUnreads {
  @override
  Future<bool> build(Channel channel) async {
    if (channel is! GuildTextChannel) return false;

    var readState = ref.watch(channelReadStateProvider);
    var lastReadMessage = readState?[channel.id]?.lastPartialMessage;
    var lastChannelMessageId = channel.lastMessageId;

    if (lastChannelMessageId == null) return false;
    if (lastReadMessage == null) return true;

    return lastChannelMessageId != lastReadMessage.id;
  }
}
