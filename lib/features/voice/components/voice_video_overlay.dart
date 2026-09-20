import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bonfire/features/voice/controllers/voice_connection.dart';
import 'package:bonfire/features/voice/services/voice_webrtc_rs_session.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A dialog for testing WebRTC video streaming end to end: hosts the local
/// camera preview (`CameraMacOSView`, whose `onCameraInizialized` callback is
/// also where `VoiceConnectionController.startLocalVideo` gets the
/// `CameraMacOSController` it needs - see that method's doc) alongside a tile
/// per remote participant's decoded frames.
///
/// Only meaningful once already connected via the WebRTC transport (see
/// `voiceUseWebRtcTransport`) - opening it before that just shows an empty
/// remote-tiles area and a local preview with nothing to send anywhere yet.
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

class _VoiceVideoOverlayState extends ConsumerState<VoiceVideoOverlay> {
  StreamSubscription<RemoteVideoFrameEvent>? _remoteFramesSub;
  final Map<Snowflake, ui.Image> _remoteImages = {};
  bool _startedLocalVideo = false;
  bool _subscribedToRemoteFrames = false;
  String? _error;

  @override
  void dispose() {
    unawaited(_remoteFramesSub?.cancel());
    if (_startedLocalVideo) {
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

  Future<void> _onLocalCameraReady(CameraMacOSController controller) async {
    if (_startedLocalVideo) return;
    _startedLocalVideo = true;
    try {
      await ref.read(voiceConnectionControllerProvider.notifier).startLocalVideo(controller);
    } catch (error, stackTrace) {
      debugPrint('VoiceVideoOverlay: startLocalVideo failed: $error\n$stackTrace');
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    _subscribeToRemoteFramesOnce();
    final theme = Theme.of(context);

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Text(
                'Video is negotiated with Discord as H264 up front, and camera on/off is announced '
                'over the gateway (opcode 12) - matching how Discord\'s own client toggles video '
                'mid-call, with no renegotiation. Frames are encoded and sent for real.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('You', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 4),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CameraMacOSView(
                                cameraMode: CameraMacOSMode.video,
                                // Capturing at the default (max - often the
                                // camera's native 1080p) makes every frame a
                                // ~8MB RGBA buffer and a genuinely expensive
                                // 1080p H264 encode (confirmed live: camera
                                // frames only arrived every ~500ms, capping
                                // the whole app at ~2fps while it ran) - a
                                // voice-channel camera doesn't need anywhere
                                // near that. `.medium` (960x540, 16:9) cuts
                                // pixel count (and so encode cost, RTP packet
                                // count, and DAVE encrypt-call count) by
                                // ~70% versus 1080p.
                                //
                                // Deliberately not `.low` (640x480, 4:3):
                                // camera_macos negotiates the camera's native
                                // *capture* format independently of this
                                // value (always 16:9 on essentially every
                                // modern webcam) and stretches it into
                                // whatever aspect ratio this setting asks
                                // for with non-uniform x/y scaling - a 4:3
                                // target visibly squishes the picture, so
                                // this must stay 16:9 (matches
                                // _videoCaptureWidth/Height in
                                // voice_webrtc_rs_session.dart).
                                resolution: PictureResolution.medium,
                                onCameraInizialized: (controller) {
                                  unawaited(_onLocalCameraReady(controller));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
          ],
        ),
      ),
    );
  }
}
