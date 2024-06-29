import 'package:bonfire/features/messaging/views/components/box/content/attachment/bounded_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

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
  VlcPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VlcPlayerController.network(
      widget.url.toString(),
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    // _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BoundedContent(
      aspectRatio: widget.width / widget.height,
      child: VlcPlayer(
        controller: _videoPlayerController!,
        aspectRatio: widget.width / widget.height,
        placeholder: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
