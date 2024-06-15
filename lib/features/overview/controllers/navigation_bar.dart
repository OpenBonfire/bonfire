import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_bar.g.dart';

/// State notifier to bound to overlapping panels navigation
@riverpod
class NavigationBar extends _$NavigationBar {
  RevealSide side = RevealSide.main;

  @override
  RevealSide build() {
    print("build called");
    return side;
  }

  void onSideChange(RevealSide side) {
    print("side change called");
    this.side = side;
    state = side;
  }
}
