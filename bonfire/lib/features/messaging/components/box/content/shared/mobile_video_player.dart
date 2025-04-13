import 'dart:async';
import 'package:bonfire/features/messaging/components/box/content/attachment/bounded_content.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class SimpleVideoPlayer extends StatefulWidget {
  final double width;
  final double height;
  final Uri url;
  final ScrollController scrollController;
  final EmbedThumbnail thumbnail;

  const SimpleVideoPlayer({
    super.key,
    required this.width,
    required this.height,
    required this.url,
    required this.scrollController,
    required this.thumbnail,
  });

  @override
  State<StatefulWidget> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  Player? player;
  VideoController? controller;
  bool _isScrolling = true;
  Timer? _scrollTimer;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_checkScrolling);

    _checkScrolling();
  }

  void _checkScrolling() {
    _scrollTimer?.cancel();

    if (!_isScrolling) {
      setState(() => _isScrolling = true);
    }
    _scrollTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _isScrolling = false);
        _initializePlayer();
      }
    });
  }

  void _initializePlayer() async {
    if (player != null || _isScrolling) return;

    player = Player();
    player!.setVolume(0);

    player!.stream.bufferingPercentage.listen((progress) {
      if ((progress == 100) && mounted && !_isVideoReady) {
        setState(() => _isVideoReady = true);
      }
    });

    controller = VideoController(player!);

    player!.stream.completed.listen((completed) {
      if (completed) {
        player!.seek(Duration.zero);
        player!.play();
      }
    });

    await player!.open(Media(widget.url.toString()));
    player!.play();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    widget.scrollController.removeListener(_checkScrolling);
    player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BoundedContent(
        aspectRatio: widget.width / widget.height,
        child: _isScrolling || !_isVideoReady || controller == null
            ? Image(
                fit: BoxFit.cover,
                image: NetworkImage(widget.thumbnail.url.toString()))
            : Video(
                controller: controller!,
                controls: NoVideoControls,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
