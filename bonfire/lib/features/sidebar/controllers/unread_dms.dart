import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unread_dms.g.dart';

@Riverpod(keepAlive: true)
class UnreadDms extends _$UnreadDms {
  @override
  List<ReadState>? build() {
    List<Channel> privateChannels =
        ref.watch(privateMessageHistoryProvider).toList();

    List<ReadState> unreadDms = [];

    for (var channel in privateChannels) {
      var readState = ref.read(channelReadStateProvider(channel.id));
      if ((readState?.mentionCount != null) && (readState!.mentionCount!) > 0) {
        unreadDms.add(readState);
      }
    }

    return unreadDms;
  }
}
