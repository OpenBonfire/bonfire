import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/channels/repositories/channels.dart';
import 'package:bonfire/shared/models/channel.dart';
import 'package:nyxx/nyxx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';

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

  BonfireChannel? getChannel() {
    var channels = ref.watch(channelsProvider.notifier).channels;
    return channels.firstWhereOrNull((channel) => channel.id == state);
  }
}
