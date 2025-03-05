import 'package:bonfire/features/messaging/components/box/content/attachment/bounded_content.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MobileVideoPlayer extends StatefulWidget {
  final double width;
  final double height;
  final Uri url;
  const MobileVideoPlayer(
      {super.key,
      required this.width,
      required this.height,
      required this.url});

  @override
  State<StatefulWidget> createState() => VideoEmbedState();
}

class VideoEmbedState extends State<MobileVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.networkUrl(
      widget.url,
    )..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BoundedContent(
        aspectRatio: widget.width / widget.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
