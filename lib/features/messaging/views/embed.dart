import 'dart:math';

import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:fireview/webview_all.dart';

class EmbedWidget extends ConsumerStatefulWidget {
  final Embed embed;
  const EmbedWidget({super.key, required this.embed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmbedWidgetState();
}

class _EmbedWidgetState extends ConsumerState<EmbedWidget> {
  String? generateEmbedKey() {
    return widget.embed.thumbnail?.url.toString() ??
        widget.embed.video?.url.toString();
  }

  @override
  Widget build(BuildContext context) {
    Widget embedWidget = Container(key: PageStorageKey(generateEmbedKey()));
    if (widget.embed.image != null) {
      embedWidget = ImageEmbed(embed: widget.embed);
    }
    if (widget.embed.video != null) {
      embedWidget = VideoEmbed(embed: widget.embed);
    }
    return embedWidget;
  }
}

class ImageEmbed extends ConsumerStatefulWidget {
  final Embed embed;
  const ImageEmbed({super.key, required this.embed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ImageEmbedState();
}

class ImageEmbedState extends ConsumerState<ImageEmbed> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: min(widget.embed.thumbnail?.width?.toDouble() ?? double.infinity,
          MediaQuery.of(context).size.width - 90),
      child: AspectRatio(
        aspectRatio: (widget.embed.thumbnail!.width?.toDouble() ?? 1) /
            (widget.embed.thumbnail!.height?.toDouble() ?? 1),
        child: Image.network(widget.embed.image!.url.toString(),
            fit: BoxFit.cover),
      ),
    );
  }
}

class VideoEmbed extends ConsumerStatefulWidget {
  final Embed embed;
  const VideoEmbed({super.key, required this.embed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => VideoEmbedState();
}

class VideoEmbedState extends ConsumerState<VideoEmbed> {
  VlcPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VlcPlayerController.network(
      widget.embed.video!.url.toString(),
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );

    _videoPlayerController!.addListener(() {
      if (_videoPlayerController!.value.playingState == PlayingState.ended) {
        _videoPlayerController!.setMediaFromNetwork(
            widget.embed.video!.url.toString(),
            autoPlay: false,
            hwAcc: HwAcc.auto);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildVideoWidget();
  }

  Widget _buildVideoWidget() {
    if (widget.embed.provider?.name == "YouTube") {
      return WebVideo(embed: widget.embed);
    }

    if (widget.embed.thumbnail?.width == null) {
      return const SizedBox();
    }

    if (widget.embed.provider?.name == "Tenor") {
      return SizedBox(
        width: min(widget.embed.thumbnail!.width!.toDouble(),
            MediaQuery.of(context).size.width - 90),
        child: AspectRatio(
          aspectRatio: (widget.embed.thumbnail!.width?.toDouble() ?? 1) /
              (widget.embed.thumbnail!.height?.toDouble() ?? 1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: VlcPlayer(
              controller: _videoPlayerController!,
              aspectRatio: widget.embed.thumbnail!.width! /
                  widget.embed.thumbnail!.height!,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: (widget.embed.thumbnail?.width ?? 1) /
          (widget.embed.thumbnail?.height ?? 1),
      child: Image.network(widget.embed.thumbnail!.url.toString(),
          fit: BoxFit.cover),
    );
  }
}

class WebVideo extends ConsumerStatefulWidget {
  final Embed embed;
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
                min(widget.embed.thumbnail!.width!.toDouble(),
                    MediaQuery.of(context).size.width - 90),
                500),
            height: height,
            child: Webview(
              url: widget.embed.video!.url!.toString(),
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
            child: Image.network(widget.embed.thumbnail!.url.toString(),
                fit: BoxFit.cover),
          );
  }

  @override
  Widget build(BuildContext context) {
    var aspect = widget.embed.thumbnail!.width!.toDouble() /
        widget.embed.thumbnail!.height!.toDouble();
    double width = min(
        min(widget.embed.thumbnail!.width!.toDouble(),
            MediaQuery.of(context).size.width - 90),
        500);

    height = width / aspect;

    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.red,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).custom.colorTheme.embedBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            widget.embed.provider?.name ?? "Provider not found",
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
