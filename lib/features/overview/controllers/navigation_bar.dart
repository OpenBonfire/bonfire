import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_bar.g.dart';

@riverpod
class NavigationBar extends _$NavigationBar {
  RevealSide side = RevealSide.main;

  @override
  RevealSide build() {
    return side;
  }

  void onSideChange(RevealSide side) {
    this.side = side;
    state = side;
  }
}
