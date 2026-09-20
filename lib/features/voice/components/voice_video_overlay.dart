import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bonfire/features/voice/controllers/voice_connection.dart';
import 'package:bonfire/features/voice/services/voice_webrtc_rs_session.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A dialog for testing WebRTC video streaming end to end: an explicit
/// camera on/off toggle (capture and hardware H264 encode both happen
/// entirely in Rust via `capture_kit`, see
/// `VoiceConnectionController.startLocalVideo`) alongside a tile per remote
/// participant's decoded frames.
///
/// There's no local self-preview here - `capture_kit` doesn't hand raw
/// frames to Dart at all (that's the whole point), so a preview would need
/// its own zero-copy path (a `Texture` via `irondash_texture`, not yet
/// wired up) rather than reusing the encode pipeline's output. The toggle
/// plus status text below are the only feedback available for now.
///
/// Only meaningful once already connected via the WebRTC transport (see
/// `voiceUseWebRtcTransport`) - opening it before that just shows an empty
/// remote-tiles area and a toggle with nothing to send anywhere yet.
class VoiceVideoOverlay extends ConsumerStatefulWidget {
  const VoiceVideoOverlay({super.key});

  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const VoiceVideoOverlay(),
    );
  }

  @override
  ConsumerState<VoiceVideoOverlay> createState() => _VoiceVideoOverlayState();
}

enum _LocalVideoStatus { off, starting, on, stopping, error }

class _VoiceVideoOverlayState extends ConsumerState<VoiceVideoOverlay> {
  StreamSubscription<RemoteVideoFrameEvent>? _remoteFramesSub;
  final Map<Snowflake, ui.Image> _remoteImages = {};
  bool _subscribedToRemoteFrames = false;
  _LocalVideoStatus _localVideoStatus = _LocalVideoStatus.off;
  String? _error;

  @override
  void dispose() {
    unawaited(_remoteFramesSub?.cancel());
    if (_localVideoStatus == _LocalVideoStatus.on || _localVideoStatus == _LocalVideoStatus.starting) {
      unawaited(ref.read(voiceConnectionControllerProvider.notifier).stopLocalVideo());
    }
    for (final image in _remoteImages.values) {
      image.dispose();
    }
    super.dispose();
  }

  void _subscribeToRemoteFramesOnce() {
    if (_subscribedToRemoteFrames) return;
    final frames = ref.read(voiceConnectionControllerProvider.notifier).remoteVideoFrames;
    if (frames == null) return;
    _subscribedToRemoteFrames = true;
    _remoteFramesSub = frames.listen(_handleRemoteFrame);
  }

  Future<void> _handleRemoteFrame(RemoteVideoFrameEvent event) async {
    final frame = event.frame;
    // DecodedVideoFrame.rgb is RGB8 (3 bytes/pixel) - dart:ui has no
    // alpha-less RGB pixel format for decodeImageFromPixels, so pad an
    // opaque alpha byte onto every pixel first.
    final rgba = Uint8List(frame.width * frame.height * 4);
    var src = 0;
    for (var dst = 0; dst < rgba.length; dst += 4) {
      rgba[dst] = frame.rgb[src];
      rgba[dst + 1] = frame.rgb[src + 1];
      rgba[dst + 2] = frame.rgb[src + 2];
      rgba[dst + 3] = 255;
      src += 3;
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(rgba, frame.width, frame.height, ui.PixelFormat.rgba8888, completer.complete);
    final image = await completer.future;

    if (!mounted) {
      image.dispose();
      return;
    }
    setState(() {
      _remoteImages.remove(event.userId)?.dispose();
      _remoteImages[event.userId] = image;
    });
  }

  Future<void> _toggleLocalVideo() async {
    if (_localVideoStatus == _LocalVideoStatus.off || _localVideoStatus == _LocalVideoStatus.error) {
      setState(() {
        _localVideoStatus = _LocalVideoStatus.starting;
        _error = null;
      });
      try {
        await ref.read(voiceConnectionControllerProvider.notifier).startLocalVideo();
        if (mounted) setState(() => _localVideoStatus = _LocalVideoStatus.on);
      } catch (error, stackTrace) {
        debugPrint('VoiceVideoOverlay: startLocalVideo failed: $error\n$stackTrace');
        if (mounted) {
          setState(() {
            _localVideoStatus = _LocalVideoStatus.error;
            _error = error.toString();
          });
        }
      }
    } else if (_localVideoStatus == _LocalVideoStatus.on) {
      setState(() => _localVideoStatus = _LocalVideoStatus.stopping);
      try {
        await ref.read(voiceConnectionControllerProvider.notifier).stopLocalVideo();
      } finally {
        if (mounted) setState(() => _localVideoStatus = _LocalVideoStatus.off);
      }
    }
  }

  String get _statusText => switch (_localVideoStatus) {
        _LocalVideoStatus.off => 'Camera off',
        _LocalVideoStatus.starting => 'Starting camera…',
        _LocalVideoStatus.on => 'Camera on - sending encoded frames',
        _LocalVideoStatus.stopping => 'Stopping camera…',
        _LocalVideoStatus.error => 'Camera failed to start',
      };

  @override
  Widget build(BuildContext context) {
    _subscribeToRemoteFramesOnce();
    final theme = Theme.of(context);
    final busy = _localVideoStatus == _LocalVideoStatus.starting || _localVideoStatus == _LocalVideoStatus.stopping;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 900,
        height: 600,
        child: Column(
          children: [
            AppBar(
              title: const Text('Video (WebRTC test)'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  IconButton.filledTonal(
                    icon: Icon(_localVideoStatus == _LocalVideoStatus.on ? Icons.videocam : Icons.videocam_off),
                    tooltip: _localVideoStatus == _LocalVideoStatus.on ? 'Turn camera off' : 'Turn camera on',
                    onPressed: busy ? null : _toggleLocalVideo,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_statusText, style: theme.textTheme.bodyMedium),
                        Text(
                          'Capture and hardware H264 encode happen natively (capture_kit) - '
                          'there is no local self-preview yet, this toggle and status are the only feedback.',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: theme.colorScheme.errorContainer,
                child: Text(_error!, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
              ),
            Expanded(
              child: _remoteImages.isEmpty
                  ? Center(
                      child: Text(
                        'Waiting for remote video…',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: _remoteImages.length,
                      itemBuilder: (context, index) {
                        final entry = _remoteImages.entries.elementAt(index);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('User ${entry.key}', style: theme.textTheme.labelMedium),
                            const SizedBox(height: 4),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: RawImage(image: entry.value),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
