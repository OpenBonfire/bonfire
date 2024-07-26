import 'package:bonfire/features/messaging/views/components/box/content/attachment/bounded_content.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/features/messaging/controllers/attachment_controller.dart';

class DesktopVideoPlayer extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final Uri url;
  const DesktopVideoPlayer(
      {super.key,
      required this.width,
      required this.height,
      required this.url});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      DesktopVideoPlayerState();
}

class DesktopVideoPlayerState extends ConsumerState<DesktopVideoPlayer> {
  // Player? player;
  // VideoController? controller;

  @override
  void initState() {
    print("initialized video player");
    // player = Player();
    // player!.open(Media(widget.url.toString()), play: false);
    // controller = VideoController(player!);
    super.initState();
  }

  @override
  void dispose() {
    // player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var controller =
        ref.watch(attachmentVideoControllerProvider(widget.url.toString()));
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BoundedContent(
        aspectRatio: widget.width / widget.height,
        minWidth: 300,
        child: Video(
          controller: controller!,
          // controls: CupertinoVideoControls,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
