import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

/// Thrown when the user denies (or has previously denied) microphone
/// access, which is required to join voice.
class VoiceMicrophonePermissionDeniedException implements Exception {
  const VoiceMicrophonePermissionDeniedException();

  @override
  String toString() => 'Microphone permission was denied - cannot join voice.';
}

/// Attribute lines kept when building the Select Protocol SDP fragment from
/// the local offer, per https://docs.discord.food/topics/voice-connections:
/// ICE/DTLS transport attributes, extension mappings, and rtpmap lines for
/// the codecs Discord's SFU understands (Opus, VP8, and the RTX payload
/// associated with VP8).
final _fragmentAttributePattern =
    RegExp(r'^a=(extmap-allow-mixed|ice-\S+|fingerprint:|extmap:\d+)');
final _fragmentRtpmapPattern =
    RegExp(r'^a=rtpmap:\d+ (opus|VP8|rtx)/', caseSensitive: false);

/// Wraps a single flutter_webrtc [RTCPeerConnection] for one voice session:
/// captures the microphone, negotiates SDP with Discord's voice SFU, and
/// exposes remote participants' audio.
///
/// This only handles the WebRTC transport - see `VoiceGateway` (in
/// `voice_gateway.dart`) for the signalling this is paired with. Transport
/// encryption (DTLS-SRTP) is automatic, handled by libwebrtc; DAVE
/// (Discord's additional E2EE layer) is not implemented, so real Discord
/// voice servers currently close the connection once they notice DAVE was
/// never negotiated (close code 4017).
class VoiceWebRtcSession {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  final _remoteStreamController = StreamController<MediaStream>.broadcast();

  /// Emits each remote participant's audio stream as it's added.
  Stream<MediaStream> get onRemoteStream => _remoteStreamController.stream;

  final _connectionStateController =
      StreamController<RTCPeerConnectionState>.broadcast();
  Stream<RTCPeerConnectionState> get onConnectionState =>
      _connectionStateController.stream;

  /// Requests microphone access, opens the peer connection, and attaches
  /// the local audio track. Must be called before
  /// [createOfferAndBuildFragment].
  ///
  /// Throws [VoiceMicrophonePermissionDeniedException] if the microphone
  /// permission isn't granted.
  Future<void> connect() async {
    debugPrint('VoiceWebRtcSession: requesting microphone permission');
    final micStatus = await Permission.microphone.request();
    debugPrint('VoiceWebRtcSession: microphone permission status=$micStatus');
    if (!micStatus.isGranted) {
      throw const VoiceMicrophonePermissionDeniedException();
    }

    final peerConnection = await createPeerConnection({
      // Discord's SFU is the only ICE peer involved; no external STUN/TURN
      // is needed (or currently known to be offered by Discord for this).
      'iceServers': <dynamic>[],
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'sdpSemantics': 'unified-plan',
    });
    _peerConnection = peerConnection;
    debugPrint('VoiceWebRtcSession: peer connection created');

    peerConnection.onTrack = (event) {
      debugPrint('VoiceWebRtcSession: onTrack kind=${event.track.kind}');
      if (event.track.kind == 'audio' && event.streams.isNotEmpty) {
        _remoteStreamController.add(event.streams.first);
      }
    };
    peerConnection.onConnectionState = (state) {
      debugPrint('VoiceWebRtcSession: connection state -> $state');
      _connectionStateController.add(state);
    };
    peerConnection.onIceConnectionState = (state) {
      debugPrint('VoiceWebRtcSession: ICE connection state -> $state');
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });
    debugPrint(
      'VoiceWebRtcSession: got local mic stream, '
      'tracks=${_localStream!.getAudioTracks().length}',
    );

    for (final track in _localStream!.getAudioTracks()) {
      await peerConnection.addTrack(track, _localStream!);
    }
  }

  /// Creates the local offer, waits for ICE gathering to finish (Discord
  /// doesn't trickle ICE - candidates are embedded directly in the
  /// fragment/answer), and returns the trimmed SDP fragment to send via
  /// `VoiceGateway.selectWebRtcProtocol`.
  Future<String> createOfferAndBuildFragment() async {
    final peerConnection = _peerConnection;
    if (peerConnection == null) {
      throw StateError('connect() must be called before this');
    }

    final offer = await peerConnection.createOffer();
    debugPrint('VoiceWebRtcSession: local offer created (${offer.sdp?.length} chars)');
    await peerConnection.setLocalDescription(offer);
    await _waitForIceGatheringComplete(peerConnection);

    final local = await peerConnection.getLocalDescription();
    final fragment = _buildFragment(local?.sdp ?? '');
    debugPrint('VoiceWebRtcSession: built fragment:\n$fragment');
    return fragment;
  }

  Future<void> _waitForIceGatheringComplete(
    RTCPeerConnection peerConnection,
  ) async {
    debugPrint(
      'VoiceWebRtcSession: waiting for ICE gathering '
      '(currently ${peerConnection.iceGatheringState})',
    );
    if (peerConnection.iceGatheringState ==
        RTCIceGatheringState.RTCIceGatheringStateComplete) {
      return;
    }

    final completer = Completer<void>();
    peerConnection.onIceGatheringState = (state) {
      debugPrint('VoiceWebRtcSession: ICE gathering state -> $state');
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete &&
          !completer.isCompleted) {
        completer.complete();
      }
    };

    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () =>
          debugPrint('VoiceWebRtcSession: ICE gathering timed out after 10s'),
    );
  }

  String _buildFragment(String sdp) {
    final lines = sdp.split(RegExp(r'\r\n|\n'));
    final kept = lines.where((line) =>
        _fragmentAttributePattern.hasMatch(line) ||
        _fragmentRtpmapPattern.hasMatch(line));
    return kept.join('\r\n');
  }

  /// Applies the SFU's SDP answer, received via
  /// `VoiceGateway.onSessionDescription`.
  Future<void> applyAnswer(String sdp) async {
    final peerConnection = _peerConnection;
    if (peerConnection == null) {
      throw StateError('connect() must be called before this');
    }
    await peerConnection.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
  }

  Future<void> setMuted(bool muted) async {
    for (final track in _localStream?.getAudioTracks() ?? const []) {
      track.enabled = !muted;
    }
  }

  Future<void> dispose() async {
    for (final track in _localStream?.getAudioTracks() ?? const []) {
      await track.stop();
    }
    await _localStream?.dispose();
    await _peerConnection?.close();
    await _peerConnection?.dispose();
    await _remoteStreamController.close();
    await _connectionStateController.close();
  }
}
