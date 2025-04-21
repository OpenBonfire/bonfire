import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channel_list_width.g.dart';

@Riverpod(keepAlive: true)
class ChannelListWidth extends _$ChannelListWidth {
  @override
  double build() {
    return 255.0;
  }

  void setSize(double size) {
    state = size;
  }
}
