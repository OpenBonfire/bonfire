import 'package:bonfire/features/messaging/views/components/box/content/attachment/bounded_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_thumbhash/flutter_thumbhash.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopVideoPlayer extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final Uri url;
  final Uri thumbnailUrl;
  final String placeholder;
  const DesktopVideoPlayer({
    super.key,
    required this.width,
    required this.height,
    required this.url,
    required this.thumbnailUrl,
    required this.placeholder,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      DesktopVideoPlayerState();
}

class DesktopVideoPlayerState extends ConsumerState<DesktopVideoPlayer> {
  Player? player;
  VideoController? controller;
  bool shouldLoadVideo = false;

  @override
  void initState() {
    // print("initialized video player");
    player = Player();
    player!.open(Media(widget.url.toString()), play: true);
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
    var url = Uri.https(
      'media.discordapp.net',
      widget.thumbnailUrl.path,
      {
        ...widget.thumbnailUrl.queryParameters,
        'format': "webp",
        'width': widget.width.toInt().toString(),
        'height': widget.height.toInt().toString(),
      },
    ).toString();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BoundedContent(
          aspectRatio: widget.width / widget.height,
          minWidth: 300,
          // ThumbHash.fromBase64(widget.attachment.placeholder!);

          child: Stack(
            children: [
              Image.network(
                url,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Image(
                      image:
                          ThumbHash.fromBase64(widget.placeholder).toImage());
                },
              ),
              shouldLoadVideo
                  ? Video(
                      controller: controller!,
                      // controls: CupertinoVideoControls,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            shouldLoadVideo = true;
                          });
                        },
                      ),
                    ),
            ],
          )),
    );
  }
}
