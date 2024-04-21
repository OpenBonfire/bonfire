import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channel.g.dart';

@riverpod
class ChannelController extends _$ChannelController {
  int? channelId;

  @override
  int? build() {
    return channelId;
  }

  int setChannel(int newChannelId) {
    channelId = newChannelId;
    state = channelId!;
    return state!;
  }
}
