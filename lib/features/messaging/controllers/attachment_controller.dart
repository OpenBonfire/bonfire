import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

part 'attachment_controller.g.dart';

@riverpod
VideoController? attachmentVideoController(
    AttachmentVideoControllerRef ref, String url) {
  Player player = Player();
  player.open(Media(url.toString()), play: false);
  return VideoController(player);
}
