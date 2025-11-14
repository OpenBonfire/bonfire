import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';

class AudioAttachment extends StatefulWidget {
  final Attachment attachment;
  const AudioAttachment({super.key, required this.attachment});

  @override
  State<AudioAttachment> createState() => _AudioAttachmentState();
}

class _AudioAttachmentState extends State<AudioAttachment> {
  AudioPlayer? player;
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  // bool get _isPaused => _playerState == PlayerState.paused;

  // String get _durationText => _duration?.toString().split('.').first ?? '';

  // String get _positionText => _position?.toString().split('.').first ?? '';

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    _playerState = player!.state;
    player!.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    player!.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );

    _initStreams();
    initAudioStream();
  }

  void initAudioStream() async {
    // await player!.setSource(UrlSource(widget.attachment.url.toString()));
    await player!.setSource(UrlSource(widget.attachment.url.toString()));
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // we want to null out ontap for other components
      onTap: () {},
      // TODO: Overlapping Panels doesn't like when we use the swipe gesture.
      child: SizedBox(
        height: 100,
        width: min(800, MediaQuery.sizeOf(context).width - 90),
        child: Container(
          decoration: BoxDecoration(
            color: BonfireThemeExtension.of(context).foreground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.attachment.fileName,
                  style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      key: const Key('play_button'),
                      onPressed: _toggle,
                      iconSize: 36,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 100),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: _isPlaying
                            ? const Icon(Icons.pause, key: ValueKey('pause'))
                            : const Icon(Icons.play_arrow,
                                key: ValueKey('play')),
                      ),
                      color: Colors.white,
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(),
                      child: Expanded(
                        child: Slider(
                          activeColor:
                              BonfireThemeExtension.of(context).primary,
                          onChanged: (value) {
                            final duration = _duration;
                            if (duration == null) {
                              return;
                            }
                            final position = value * duration.inMilliseconds;
                            player!
                                .seek(Duration(milliseconds: position.round()));
                          },
                          value: (_position != null &&
                                  _duration != null &&
                                  _position!.inMilliseconds > 0 &&
                                  _position!.inMilliseconds <
                                      _duration!.inMilliseconds)
                              ? _position!.inMilliseconds /
                                  _duration!.inMilliseconds
                              : 0.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _initStreams() {
    _durationSubscription = player!.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player!.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = player!.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription =
        player!.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _pause();
    } else {
      await _play();
    }
  }

  Future<void> _play() async {
    // debugPrint("resuming...");

    if (_position == Duration.zero) {
      await player!.play(UrlSource(widget.attachment.url.toString()));
    } else {
      await player!.resume();
    }

    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player!.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  // Future<void> _stop() async {
  //   await player!.stop();
  //   setState(() {
  //     _playerState = PlayerState.stopped;
  //     _position = Duration.zero;
  //   });
  // }
}
