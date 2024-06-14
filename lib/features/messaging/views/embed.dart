import 'dart:math';

import 'package:bonfire/shared/models/embed.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:fireview/webview_all.dart';
import 'package:visibility_detector/visibility_detector.dart';

class EmbedWidget extends ConsumerStatefulWidget {
  final BonfireEmbed embed;
  const EmbedWidget({super.key, required this.embed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmbedWidgetState();
}

class _EmbedWidgetState extends ConsumerState<EmbedWidget> {
  @override
  Widget build(BuildContext context) {
    Widget embedWidget = Container();
    if (widget.embed.type == EmbedType.image) {
      embedWidget = ImageEmbed(embed: widget.embed);
    }
    if (widget.embed.type == EmbedType.video) {
      embedWidget = VideoEmbed(embed: widget.embed);
    }
    return embedWidget;
  }
}

class ImageEmbed extends ConsumerStatefulWidget {
  final BonfireEmbed embed;
  const ImageEmbed({super.key, required this.embed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ImageEmbedState();
}

class ImageEmbedState extends ConsumerState<ImageEmbed> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: min(widget.embed.thumbnailWidth?.toDouble() ?? double.infinity,
          MediaQuery.of(context).size.width - 90),
      child: AspectRatio(
        aspectRatio: (widget.embed.thumbnailWidth ?? 1) /
            (widget.embed.thumbnailHeight ?? 1),
        child: Image.network(widget.embed.imageUrl!, fit: BoxFit.cover),
      ),
    );
  }
}

class VideoEmbed extends ConsumerStatefulWidget {
  final BonfireEmbed embed;
  const VideoEmbed({super.key, required this.embed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => VideoEmbedState();
}

class VideoEmbedState extends ConsumerState<VideoEmbed> {
  // Create a [Player] to control playback.
  var player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    if (widget.embed.proxiedUrl != null) {
      print("VIDEO URL");
      print(widget.embed.proxiedUrl);
    } else {
      print("video url null!");
    }
    isVisibleThread();
  }

  void isVisibleThread() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 1000));
      // if (_isVisible) print("VIDEO VISIBLE!");
    }
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
    if (widget.embed.provider == "YouTube") {
      return WebVideo(embed: widget.embed);
    }

    if (widget.embed.proxiedUrl != null) {
      player.open(Media(widget.embed.proxiedUrl!));
      player.pause();
      // player.setPlaylistMode(PlaylistMode.loop);
      player.setVolume(100);
    }

    if (widget.embed.thumbnailWidth == null) {
      return const SizedBox();
    }

    return (widget.embed.provider != "Tenor")
        ? SizedBox(
            width: min(widget.embed.thumbnailWidth?.toDouble() ?? 200,
                MediaQuery.of(context).size.width - 90),
            child: AspectRatio(
              aspectRatio: (widget.embed.thumbnailWidth ?? 1) /
                  (widget.embed.thumbnailHeight ?? 1),
              child:
                  Image.network(widget.embed.thumbnailUrl!, fit: BoxFit.cover),
            ),
          )
        : Container(
            height: widget.embed.thumbnailHeight!.toDouble(),
            width: min(widget.embed.thumbnailWidth!.toDouble(),
                MediaQuery.of(context).size.width - 90),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (widget.embed.videoUrl != null)
                  ? Video(
                      controller: controller,
                      fit: BoxFit.cover,
                    )
                  : const Text("URL is null"),
            ),
          );
  }
}

class WebVideo extends ConsumerStatefulWidget {
  final BonfireEmbed embed;
  const WebVideo({super.key, required this.embed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WebVideoState();
}

class _WebVideoState extends ConsumerState<WebVideo> {
  bool _isPlaying = false;
  double height = 200;

  Widget embedWidget() {
    return _isPlaying
        ? SizedBox(
            width: min(
                min(widget.embed.thumbnailWidth!.toDouble(),
                    MediaQuery.of(context).size.width - 90),
                500),
            height: height,
            child: Webview(
              url: widget.embed.videoUrl!,
            ))
        : OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              side: const BorderSide(
                color: Color.fromARGB(0, 255, 255, 255),
                width: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            onPressed: () {
              setState(() {
                _isPlaying = true;
                // force a second state update
                // pretty ugly solution, but reliable
                Future.delayed(const Duration(milliseconds: 200), () {
                  setState(() {
                    _isPlaying = true;
                  });
                });
              });
            },
            child: Image.network(widget.embed.thumbnailUrl!, fit: BoxFit.cover),
          );
  }

  @override
  Widget build(BuildContext context) {
    var aspect = widget.embed.thumbnailWidth! / widget.embed.thumbnailHeight!;
    double width = min(
        min(widget.embed.thumbnailWidth!.toDouble(),
            MediaQuery.of(context).size.width - 90),
        500);

    height = width / aspect;

    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.redColor,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).custom.colorTheme.brightestGray,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.embed.provider ?? "Provider not found",
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .custom
                                .textTheme
                                .bodyText2
                                .copyWith(
                                    color: const Color.fromARGB(
                                        255, 172, 172, 172),
                                    fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(widget.embed.title ?? "Title not found",
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .custom
                                .textTheme
                                .bodyText2
                                .copyWith(fontSize: 14)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width.toDouble(),
                    child: embedWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
