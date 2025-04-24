import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channel_list_width.g.dart';

@Riverpod(keepAlive: true)
class ChannelListWidth extends _$ChannelListWidth {
  @override
  int build() {
    return 255;
  }

  void setSize(int size) {
    state = size;
  }
}
