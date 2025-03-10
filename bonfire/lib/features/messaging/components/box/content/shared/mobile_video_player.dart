import 'package:bonfire/features/messaging/components/box/content/attachment/bounded_content.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class SimpleVideoPlayer extends StatefulWidget {
  final double width;
  final double height;
  final Uri url;
  const SimpleVideoPlayer(
      {super.key,
      required this.width,
      required this.height,
      required this.url});

  @override
  State<StatefulWidget> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  Player? player;
  VideoController? controller;
  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        player = Player();
        player!.setVolume(0);
        player!
            .open(Media(widget.url.toString()), play: true);
        controller = VideoController(player!);
player!.stream.completed.listen((completed) {
        if (completed) {
          player!.seek(Duration.zero); 
          player!.play();
        }
      });
        player!.play();
        
    },);
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
        child:                  (controller != null ) ? Video(
                      controller: controller!,
                      // disable controls
                     controls: NoVideoControls,
                     
                      fit: BoxFit.contain,
                    ): const SizedBox()
      ),
    );
  }
}
