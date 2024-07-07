import 'package:bonfire/features/messaging/views/components/box/content/attachment/bounded_content.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class DesktopVideoPlayer extends StatefulWidget {
  final double width;
  final double height;
  final Uri url;
  const DesktopVideoPlayer(
      {super.key,
      required this.width,
      required this.height,
      required this.url});

  @override
  State<StatefulWidget> createState() => VideoAttachmentState();
}

class VideoAttachmentState extends State<DesktopVideoPlayer> {
  Player? player;
  VideoController? controller;

  @override
  void initState() {
    player = Player();
    player!.open(Media(widget.url.toString()));
    player!.pause();
    controller = VideoController(player!);
    super.initState();
  }

  @override
  void dispose() {
    player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
