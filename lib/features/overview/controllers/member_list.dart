import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_list.g.dart';

@Riverpod(keepAlive: true)
class MemberListVisibility extends _$MemberListVisibility {
  bool isVisible = true;

  @override
  bool build() {
    return isVisible;
  }

  void setVisibility(bool visibility) {
    isVisible = visibility;
    state = isVisible;
  }

  void toggleVisibility() {
    isVisible = !isVisible;
    state = isVisible;
  }
}
