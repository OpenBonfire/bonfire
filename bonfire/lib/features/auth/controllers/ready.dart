import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ready.g.dart';

@riverpod
class ReadyController extends _$ReadyController {
  @override
  bool build() {
    return false;
  }

  void setReady(bool isReady) {
    state = isReady;
  }
}
