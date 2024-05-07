import 'dart:math';

import 'package:bonfire/shared/models/embed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:webview_windows/webview_windows.dart';

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
      width: widget.embed.width!.toDouble(),
      height: widget.embed.height!.toDouble(),
      child: Image.network(widget.embed.imageUrl!),
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
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);
  // https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4

  final _controller = WebviewController();
  

  @override
  void initState() {
    super.initState();
    _controller.initialize();

    if (widget.embed.proxiedUrl != null) {
      print("VIDEO URL");
      print(widget.embed.proxiedUrl);
    } else {
      print("video url null!");
    }
  }

  @override
  Widget build(BuildContext context) {

    print("--");
    print(widget.embed.provider);
    print(widget.embed.videoUrl);
    print(widget.embed.proxiedUrl);
    print("--");

    if (widget.embed.provider == "YouTube") {
      print("WEBVIEW!!");
      _controller.loadUrl(widget.embed.videoUrl!);
      return SizedBox(
        width: 400,
        height: 200,
        child: Webview(
          _controller,
          width: 100,
          height: 100,
        ),
      );
    }

    if (widget.embed.proxiedUrl != null) {
      player.open(Media(widget.embed.proxiedUrl!));
      player.setPlaylistMode(PlaylistMode.loop);
    }

    return (widget.embed.provider != "Tenor")
        ? Image.network(
            width: min(widget.embed.width!.toDouble(), 500),
            widget.embed.thumbnailUrl!)
        : Container(
            height: widget.embed.height!.toDouble(),
            width: min(widget.embed.width!.toDouble(), 500),
            child: ClipRRect(
              // widget.embed.videoUrl!
              borderRadius: BorderRadius.circular(12),
              child: (widget.embed.videoUrl != null)
                  ? Video(
                      controller: controller,
                    )
                  : const Text("URL is null"),
            ));
  }
}
