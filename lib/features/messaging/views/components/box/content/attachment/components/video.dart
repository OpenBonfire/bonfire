import 'dart:math';

import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoAttachment extends StatefulWidget {
  final Attachment attachment;
  const VideoAttachment({super.key, required this.attachment});

  @override
  State<StatefulWidget> createState() => VideoAttachmentState();
}

class VideoAttachmentState extends State<VideoAttachment> {
  var player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.open(Media(widget.attachment.url.toString()));
  }

  @override
  void dispose() {
    print('DISPOSING EMBED!!!');
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildVideoWidget();
  }

  Widget _buildVideoWidget() {
    return SizedBox(
      height: min(widget.attachment.height!.toDouble(), 400),
      width: min(
          700,
          min(widget.attachment.width!.toDouble(),
              MediaQuery.of(context).size.width - 90)),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Video(
            controller: controller,
            fit: BoxFit.cover,
          )),
    );
  }
}
