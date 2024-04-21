import 'package:bonfire/features/channels/repositories/channels.dart';
import 'package:bonfire/features/guild/repositories/guilds.dart';
import 'package:bonfire/shared/models/channel.dart';
import 'package:bonfire/shared/models/guild.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channel.g.dart';

@riverpod
class ChannelController extends _$ChannelController {
  int? channelId;
  List<BonfireChannel> channels = [];

  @override
  int? build() {
    var channelOutput = ref.watch(channelsProvider);
    channelOutput.when(
        data: (newChannels) {
          channels = newChannels;
        },
        error: (data, trace) {},
        loading: () {});

    return channelId;
  }

  int setChannel(int newChannelId) {
    print("set channel!");
    print(newChannelId);
    channelId = newChannelId;
    state = channelId!;
    return state!;
  }
}
