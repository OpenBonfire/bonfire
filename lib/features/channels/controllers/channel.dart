import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channel.g.dart';

@riverpod
class ChannelController extends _$ChannelController {
  Channel? channel;

  @override
  Channel? build() {
    return channel;
  }

  Channel setChannel(Channel newChannel) {
    channel = newChannel;
    state = channel!;
    return state!;
  }

  Channel? getChannel() {
    return state;
  }
}
