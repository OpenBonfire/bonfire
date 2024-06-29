import 'dart:math';

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
  var player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.open(Media(widget.url.toString()));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildVideoWidget();
  }

  Widget _buildVideoWidget() {
    return SizedBox(
      height: min(widget.height.toDouble(), 400),
      width: min(700,
          min(widget.width.toDouble(), MediaQuery.of(context).size.width - 90)),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Video(
            controller: controller,
            fit: BoxFit.cover,
          )),
    );
  }
}
