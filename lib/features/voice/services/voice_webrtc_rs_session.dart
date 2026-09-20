import 'dart:async';
import 'dart:typed_data';

import 'package:camera_macos/camera_macos.dart';
import 'package:dave/dave.dart' as dave;
import 'package:firebridge/firebridge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter_webrtc_rs/flutter_webrtc_rs.dart';
import 'package:opus/opus.dart' as opus;
import 'package:record/record.dart';

import 'dave_voice_session.dart';
import 'voice_gateway.dart';

const _sampleRate = 48000;
const _channels = 1;
const _samplesPerFrame = 960; // 20ms at 48kHz
const _bytesPerFrame = _samplesPerFrame * _channels * 2; // 16-bit PCM
const _frameDurationMicros = 20000; // 20ms, matching _samplesPerFrame
const _videoBitrateBps = 1_000_000;
// 15fps target for the encoder's timestamp math - the encoder itself doesn't
// enforce a frame rate; frames just get sent whenever the camera delivers
// one, at whatever cadence that actually is.
const _videoFrameDurationMicros = 1000000 ~/ 15;

/// Attribute lines kept when building the Select Protocol SDP fragment from
/// the local offer, per https://docs.discord.food/topics/voice-connections:
/// ICE/DTLS transport attributes, extension mappings, and Opus/H264 rtpmap
/// lines. Carried over from an earlier `flutter_webrtc`-based attempt at this
/// (see git history) - the audio half is now **confirmed working** against a
/// live Discord voice server; the video half (H264 rtpmap kept here, and
/// `VoiceGateway.selectWebRtcProtocol`'s `videoPayloadType`) is new and
/// unverified.
final _fragmentAttributePattern = RegExp(r'^a=(extmap-allow-mixed|ice-\S+|fingerprint:|extmap:\d+)');
final _fragmentRtpmapPattern = RegExp(r'^a=rtpmap:\d+ (opus|h264)/', caseSensitive: false);
final _opusPayloadTypePattern = RegExp(r'^a=rtpmap:(\d+) opus/', caseSensitive: false);
final _h264PayloadTypePattern = RegExp(r'^a=rtpmap:(\d+) h264/', caseSensitive: false);

/// Thrown when microphone permission isn't granted.
class VoiceMicrophonePermissionDeniedException implements Exception {
  const VoiceMicrophonePermissionDeniedException();
  @override
  String toString() => 'Microphone permission was denied - cannot join voice.';
}

/// One decoded video frame from a remote participant, emitted on
/// [VoiceWebRtcRsSession.onRemoteVideoFrame].
class RemoteVideoFrameEvent {
  const RemoteVideoFrameEvent({required this.userId, required this.frame});
  final Snowflake userId;
  final DecodedVideoFrame frame;
}

/// The real-ICE/DTLS-SRTP alternative to [VoiceMediaSession]'s hand-rolled
/// raw-UDP transport, built on `flutter_webrtc_rs` (webrtc-rs bound via
/// flutter_rust_bridge - see `packages/flutter_webrtc_rs`).
///
/// **Status: unverified against a live Discord voice server.** The wire
/// shape of WebRTC-mode Select Protocol (see
/// `VoiceGateway.selectWebRtcProtocol`) was never confirmed working even in
/// an earlier `flutter_webrtc`-based attempt at this - if the SFU never
/// replies with a Session Description carrying `sdp`, or the connection
/// never leaves `IceConnectionState.checking`, that unverified wire shape is
/// the first thing to check, not this class's webrtc-rs usage (which is
/// exercised end-to-end by `packages/flutter_webrtc_rs`'s own tests against
/// a loopback peer, so the plumbing itself is sound).
///
/// Structured to mirror [VoiceMediaSession] closely (same mic-capture/Opus/
/// DAVE/SoLoud pieces) so the two are easy to compare - the difference is
/// entirely in the transport: no manual UDP socket, no
/// `VoiceTransportCrypto` (DTLS-SRTP replaces it, automatically), and no
/// hand-rolled `RtpPacket` (webrtc-rs packetizes/depacketizes). One thing
/// that falls out of using a real RTP parser rather than the hand-rolled
/// one: incoming payloads here are already free of any RTP header extension
/// bytes (webrtc-rs's parser puts those in the packet header, not the
/// payload) - `VoiceMediaSession._handleRtpPacket`'s manual
/// `extensionWordCount * 4` stripping has no equivalent need here.
class VoiceWebRtcRsSession {
  VoiceWebRtcRsSession({
    required this.gateway,
    required this.selfUserId,
    this.daveSession,
  });

  final VoiceGateway gateway;
  final Snowflake selfUserId;

  /// When non-null, outgoing/incoming frames are DAVE-encrypted/decrypted
  /// using ratchets this emits. When null, media is sent/received as plain
  /// Opus (DTLS-SRTP transport encryption still applies either way).
  final DaveVoiceSession? daveSession;

  RtcPeerConnection? _peerConnection;
  StreamSubscription<PeerConnectionEvent>? _eventsSub;
  RtcMediaSender? _audioSender;
  RtcMediaSender? _videoSender;
  int? _ssrc;
  int? _opusPayloadType;
  int? _videoPayloadType;

  StreamSubscription<DaveRatchetUpdate>? _ratchetSub;
  dave.DaveEncryptor? _encryptor;
  final Map<Snowflake, _RemoteParticipant> _participantsByUserId = {};
  final Map<int, Snowflake> _userIdBySsrc = {};
  // Remote tracks can arrive before handleSpeaking tells us whose SSRC it
  // is (the two come from independent gateway/RTP races) - queued here and
  // drained by handleSpeaking, mirroring how VoiceMediaSession's incoming
  // packets are simply dropped until the SSRC->user mapping shows up
  // (fine there because it's just one dropped audio frame; here a whole
  // *track* would otherwise be silently lost forever, which is worse).
  final Map<int, RtcRemoteTrack> _pendingTracksBySsrc = {};

  opus.OpusEncoder? _opusEncoder;
  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _micSubscription;
  final BytesBuilder _micBuffer = BytesBuilder(copy: false);

  H264Encoder? _videoEncoder;
  CameraMacOSController? _cameraController;
  final Map<Snowflake, H264Decoder> _videoDecodersByUserId = {};
  final Map<Snowflake, Future<void>> _videoProcessingChains = {};
  final _remoteVideoFrameController = StreamController<RemoteVideoFrameEvent>.broadcast();

  /// Decoded video frames from remote participants - one event per decoded
  /// picture, tagged with which participant it came from. The UI layer owns
  /// turning these into pixels on screen (see `dart:ui`'s
  /// `decodeImageFromPixels` for the simplest path from [DecodedVideoFrame]'s
  /// RGB8 bytes to a paintable `ui.Image`).
  Stream<RemoteVideoFrameEvent> get onRemoteVideoFrame => _remoteVideoFrameController.stream;

  bool _disposed = false;

  /// The payload type Discord's SFU should expect Opus RTP packets on - only
  /// meaningful after [createOfferAndBuildFragment] returns; pass to
  /// [VoiceGateway.selectWebRtcProtocol].
  int? get opusPayloadType => _opusPayloadType;

  /// As [opusPayloadType], for H264 - null unless [startLocalVideo] was
  /// called before [createOfferAndBuildFragment] (video only gets negotiated
  /// if there's a video sender to negotiate).
  int? get videoPayloadType => _videoPayloadType;

  /// Opens the peer connection, creates the local Opus sender, waits for
  /// ICE gathering to finish (Discord doesn't trickle ICE for this - the
  /// full candidate set must be embedded in the fragment), and returns the
  /// trimmed SDP fragment to send via [VoiceGateway.selectWebRtcProtocol].
  ///
  /// Must be called before [applyAnswer]. Unlike [VoiceMediaSession], there
  /// is no separate IP-discovery step - ICE candidate gathering replaces it.
  Future<String> createOfferAndBuildFragment() async {
    final eventsDone = Completer<void>();
    final pc = await RtcPeerConnection.create(
      config: const RtcConfig(iceServers: [], udpBindAddrs: ['0.0.0.0:0']),
    );
    _peerConnection = pc;

    final gatherComplete = Completer<void>();
    _eventsSub = pc.events().listen((event) {
      _handlePeerConnectionEvent(event, gatherComplete);
    }, onDone: eventsDone.complete);

    debugPrint('VoiceWebRtcRsSession: requesting microphone permission');
    final recorder = AudioRecorder();
    _recorder = recorder;
    if (!await recorder.hasPermission()) {
      throw const VoiceMicrophonePermissionDeniedException();
    }

    // Added before creating the offer so the initial offer already
    // negotiates a send m=audio section, rather than needing a
    // renegotiation round-trip immediately after.
    _audioSender = await pc.addMediaSender(kind: MediaKind.audio, mimeType: 'audio/opus');

    final offer = await pc.createOffer();
    await pc.setLocalDescription(descriptionJson: offer);
    debugPrint('VoiceWebRtcRsSession: local offer created, waiting for ICE gathering');

    await gatherComplete.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => debugPrint('VoiceWebRtcRsSession: ICE gathering timed out after 10s'),
    );

    final sdp = _extractSdp(await pc.localDescription()) ?? '';
    _opusPayloadType = _firstGroupMatch(_opusPayloadTypePattern, sdp);
    _videoPayloadType = _firstGroupMatch(_h264PayloadTypePattern, sdp);
    final fragment = _buildFragment(sdp);
    debugPrint(
      'VoiceWebRtcRsSession: built fragment (opusPT=$_opusPayloadType videoPT=$_videoPayloadType):\n$fragment',
    );
    return fragment;
  }

  /// Starts local camera capture and adds a video sender - call before
  /// [createOfferAndBuildFragment] so the initial offer negotiates a send
  /// m=video section (matching how the audio sender is added early in
  /// [createOfferAndBuildFragment] itself). `controller` comes from a
  /// `CameraMacOSView`'s `onCameraInizialized` callback - this class doesn't
  /// own camera UI/lifecycle (see class doc), just what happens to the
  /// frames once the camera is already running.
  Future<void> startLocalVideo(CameraMacOSController controller) async {
    final pc = _peerConnection;
    if (pc == null) {
      throw StateError('createOfferAndBuildFragment() must not have been called yet - see doc');
    }
    _cameraController = controller;
    _videoEncoder = await H264Encoder.create(bitrateBps: _videoBitrateBps);
    _videoSender = await pc.addMediaSender(kind: MediaKind.video, mimeType: 'video/H264');
    await controller.startImageStream(_handleCameraFrame);
    debugPrint('VoiceWebRtcRsSession: local video started');
  }

  void _handleCameraFrame(CameraImageData? image) {
    if (image == null) return;
    final encoder = _videoEncoder;
    final sender = _videoSender;
    if (encoder == null || sender == null) return;

    // camera_macos may pad each row to a stride wider than `width * 4` -
    // H264Encoder.encodeBgra8 expects tightly packed BGRA8 (no per-row
    // padding), so strip it here if present rather than pushing stride
    // handling into the Rust encoder for what's normally a no-op copy.
    final expectedRowBytes = image.width * 4;
    final Uint8List bgra;
    if (image.bytesPerRow == expectedRowBytes) {
      bgra = image.bytes;
    } else {
      bgra = Uint8List(expectedRowBytes * image.height);
      for (var row = 0; row < image.height; row++) {
        final srcOffset = row * image.bytesPerRow;
        bgra.setRange(
          row * expectedRowBytes,
          (row + 1) * expectedRowBytes,
          image.bytes.sublist(srcOffset, srcOffset + expectedRowBytes),
        );
      }
    }

    unawaited(_encodeAndSendVideoFrame(encoder, sender, bgra, image.width, image.height));
  }

  Future<void> _encodeAndSendVideoFrame(
    H264Encoder encoder,
    RtcMediaSender sender,
    Uint8List bgra,
    int width,
    int height,
  ) async {
    try {
      final encoded = await encoder.encodeBgra8(data: bgra, width: width, height: height);
      if (encoded.isEmpty) return;
      // DAVE video encryption isn't wired up yet (see class doc) - sent as
      // plain H264 for now, same TODO as the rest of this first pass.
      await sender.writeEncodedFrame(data: encoded, durationMicros: BigInt.from(_videoFrameDurationMicros));
    } catch (error, stackTrace) {
      debugPrint('VoiceWebRtcRsSession: failed to send video frame: $error\n$stackTrace');
    }
  }

  int? _firstGroupMatch(RegExp pattern, String sdp) {
    for (final line in sdp.split(RegExp(r'\r\n|\n'))) {
      final match = pattern.firstMatch(line);
      if (match != null) return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Applies the SFU's SDP answer, received via
  /// [VoiceGateway.onSessionDescription]'s [VoiceSessionDescription.sdp],
  /// and starts mic capture. Once this returns, outgoing audio is flowing
  /// (DAVE-encrypted once ratchets arrive, plain Opus until then) and
  /// incoming tracks will start surfacing via [handleSpeaking] pairing with
  /// [PeerConnectionEvent_RemoteTrack] events.
  Future<void> applyAnswer(String sdp) async {
    final pc = _peerConnection;
    if (pc == null) {
      throw StateError('createOfferAndBuildFragment() must be called before this');
    }

    // `sdp` here is Discord's answer *fragment*, in the same trimmed shape
    // as the offer fragment this class sent - wrap it back into a full
    // RTCSessionDescription JSON object for setRemoteDescription. Discord's
    // answer is presumed to need the same "type":"answer" wrapping any real
    // SDP answer needs; unverified, like the rest of this wire format (see
    // class doc).
    await pc.setRemoteDescription(descriptionJson: _wrapAsAnswerJson(sdp));

    if (!SoLoud.instance.isInitialized) {
      await SoLoud.instance.init();
    }

    final encryptor = dave.DaveEncryptor()..passthroughMode = true;
    final ssrc = _ssrc;
    if (ssrc != null) {
      encryptor.assignSsrcToCodec(ssrc, dave.DAVECodec.DAVE_CODEC_OPUS);
    } else {
      debugPrint(
        'VoiceWebRtcRsSession: applyAnswer() called with no local ssrc known yet - '
        'DAVE encryption may silently no-op for early frames.',
      );
    }
    _encryptor = encryptor;

    _ratchetSub = daveSession?.onRatchetUpdate.listen(_handleRatchetUpdate);
    final known = daveSession?.knownRatchets;
    if (known != null) {
      for (final entry in known.entries) {
        _handleRatchetUpdate(
          DaveRatchetUpdate(userId: entry.key, ratchet: entry.value, isSelf: entry.key == selfUserId),
        );
      }
    }

    _opusEncoder = opus.OpusEncoder(sampleRate: _sampleRate, channels: _channels);
    final micStream = await _recorder!.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: _channels,
    ));
    _micSubscription = micStream.listen(_handleMicData);

    debugPrint('VoiceWebRtcRsSession: started (dave=${daveSession != null})');
  }

  void _handleRatchetUpdate(DaveRatchetUpdate update) {
    if (update.isSelf) {
      _encryptor!.setKeyRatchet(update.ratchet);
      _encryptor!.passthroughMode = false;
      debugPrint('[VoiceDave/rtc] self key ratchet updated, DAVE encryption active');
    } else {
      _participant(update.userId).decryptor.transitionToKeyRatchet(update.ratchet);
      _participant(update.userId).decryptor.transitionToPassthroughMode(false);
      _participant(update.userId)._hasRatchet = true;
      debugPrint('[VoiceDave/rtc] key ratchet updated for ${update.userId}');
    }
  }

  void _handlePeerConnectionEvent(PeerConnectionEvent event, Completer<void> gatherComplete) {
    switch (event) {
      case PeerConnectionEvent_IceGatheringStateChanged(:final field0):
        if (field0 == IceGatheringState.complete && !gatherComplete.isCompleted) {
          gatherComplete.complete();
        }
      case PeerConnectionEvent_ConnectionStateChanged(:final field0):
        debugPrint('VoiceWebRtcRsSession: connection state -> $field0');
      case PeerConnectionEvent_IceConnectionStateChanged(:final field0):
        debugPrint('VoiceWebRtcRsSession: ICE connection state -> $field0');
      case PeerConnectionEvent_RemoteTrack(:final trackId, :final kind):
        unawaited(_handleRemoteTrack(trackId, kind));
      default:
        break;
    }
  }

  Future<void> _handleRemoteTrack(String trackId, MediaKind kind) async {
    final pc = _peerConnection;
    if (pc == null) return;
    final track = await pc.takeRemoteTrack(trackId: trackId);

    // The SSRC isn't exposed on the RtcRemoteTrack handle itself (only on
    // each packet as it arrives) - peek the first packet to learn it, then
    // hand off to the real per-packet handler below. If a Speaking event
    // already told us this SSRC's user, route immediately; otherwise queue
    // the track (see field doc) until handleSpeaking catches up.
    final packets = track.packets();
    StreamSubscription<RemoteRtpPacket>? peekSub;
    peekSub = packets.listen((packet) {
      peekSub?.cancel();
      final userId = _userIdBySsrc[packet.ssrc];
      if (userId != null) {
        _startReceiving(userId, kind, packet, packets);
      } else {
        _pendingTracksBySsrc[packet.ssrc] = track;
        // Re-deliver this first packet once handleSpeaking resolves it -
        // simplest is to just resubscribe from scratch once known, so
        // nothing needs to buffer packets by hand here.
        unawaited(_waitForSsrcThenReceive(packet.ssrc, kind, packets));
      }
    });
  }

  Future<void> _waitForSsrcThenReceive(int ssrc, MediaKind kind, Stream<RemoteRtpPacket> packets) async {
    while (!_disposed && !_userIdBySsrc.containsKey(ssrc)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (_disposed) return;
    final userId = _userIdBySsrc[ssrc];
    if (userId == null) return;
    _pendingTracksBySsrc.remove(ssrc);
    packets.listen((packet) => _routeRemotePacket(userId, kind, packet));
  }

  void _startReceiving(Snowflake userId, MediaKind kind, RemoteRtpPacket firstPacket, Stream<RemoteRtpPacket> packets) {
    _routeRemotePacket(userId, kind, firstPacket);
    packets.listen((packet) => _routeRemotePacket(userId, kind, packet));
  }

  void _routeRemotePacket(Snowflake userId, MediaKind kind, RemoteRtpPacket packet) {
    if (kind == MediaKind.video) {
      // Chained rather than fire-and-forget: the H264 decoder is stateful
      // and must see packets in arrival order (it reassembles reference
      // frames across calls) - awaiting each `decode()` before starting the
      // next preserves that even though decode is an async FRB call, at the
      // cost of decode work never running concurrently with itself for one
      // participant (fine; it's already serialized by a Mutex on the Rust
      // side, so this isn't giving up real parallelism).
      final previous = _videoProcessingChains[userId] ?? Future<void>.value();
      _videoProcessingChains[userId] = previous.then((_) => _decodeRemoteVideoPacket(userId, packet));
    } else {
      _handleRemotePacket(userId, packet);
    }
  }

  Future<H264Decoder> _videoDecoderFor(Snowflake userId) async {
    final existing = _videoDecodersByUserId[userId];
    if (existing != null) return existing;
    final decoder = await H264Decoder.create();
    _videoDecodersByUserId[userId] = decoder;
    return decoder;
  }

  Future<void> _decodeRemoteVideoPacket(Snowflake userId, RemoteRtpPacket packet) async {
    try {
      // DAVE video decryption isn't wired up yet (see startLocalVideo's doc
      // for the send-side equivalent) - packet.payload is decoded as plain
      // H264 for now.
      final decoder = await _videoDecoderFor(userId);
      final frame = await decoder.decode(data: packet.payload);
      if (frame != null && !_disposed) {
        _remoteVideoFrameController.add(RemoteVideoFrameEvent(userId: userId, frame: frame));
      }
    } catch (error, stackTrace) {
      debugPrint(
        'VoiceWebRtcRsSession: failed to decode remote video packet from $userId: $error\n$stackTrace',
      );
    }
  }

  void _handleRemotePacket(Snowflake userId, RemoteRtpPacket packet) {
    final participant = _participant(userId);
    final localSeq = participant._receivedCount++;

    dave.DaveDecryptResult? result;
    Uint8List? opusFrame;
    try {
      // No transport decrypt and no RTP-extension stripping needed here -
      // both are handled below the Dart boundary (DTLS-SRTP inside
      // webrtc-rs; extension bytes never enter `payload` in the first
      // place - see the class doc).
      result = participant.decryptor.decrypt(
        mediaType: dave.DAVEMediaType.DAVE_MEDIA_TYPE_AUDIO,
        encryptedFrame: packet.payload,
      );
      opusFrame = result.isSuccess ? result.frame : packet.payload;

      if (localSeq < 5 || localSeq % 250 == 0) {
        debugPrint(
          '[VoiceRecv/rtc] #$localSeq rtpSeq=${packet.sequenceNumber} ssrc=${packet.ssrc} '
          'wire=${packet.payload.length}B decryptCode=${result.code} chosenFrame=${opusFrame.length}B '
          'hasRatchet=${participant._hasRatchet}',
        );
      }

      final pcm = participant.opusDecoder.decode(opusFrame, frameSize: _samplesPerFrame);
      SoLoud.instance.addAudioDataStream(participant.audioSource, pcm.buffer.asUint8List());
    } catch (error) {
      debugPrint(
        'VoiceWebRtcRsSession: failed to process incoming packet from $userId '
        '(#$localSeq rtpSeq=${packet.sequenceNumber}, wire=${packet.payload.length}B, '
        'decryptCode=${result?.code}, chosenFrame=${opusFrame?.length}B): $error',
      );
    }
  }

  // --- Sending ---

  void _handleMicData(Uint8List chunk) {
    _micBuffer.add(chunk);
    final buffered = _micBuffer.toBytes();
    var offset = 0;
    while (buffered.length - offset >= _bytesPerFrame) {
      final frame = Uint8List.sublistView(buffered, offset, offset + _bytesPerFrame);
      unawaited(_sendFrame(Int16List.sublistView(frame)));
      offset += _bytesPerFrame;
    }
    _micBuffer.clear();
    if (offset < buffered.length) {
      _micBuffer.add(buffered.sublist(offset));
    }
  }

  Future<void> _sendFrame(Int16List pcm) async {
    final encoder = _opusEncoder;
    final encryptor = _encryptor;
    final sender = _audioSender;
    final ssrc = _ssrc;
    if (encoder == null || encryptor == null || sender == null) return;

    try {
      final opusFrame = encoder.encode(pcm, frameSize: _samplesPerFrame);

      final encryptResult = encryptor.encrypt(
        mediaType: dave.DAVEMediaType.DAVE_MEDIA_TYPE_AUDIO,
        ssrc: ssrc ?? 0,
        frame: opusFrame,
      );
      final davePayload = encryptResult.isSuccess ? encryptResult.frame : opusFrame;

      await sender.writeEncodedFrame(data: davePayload, durationMicros: BigInt.from(_frameDurationMicros));
    } catch (error, stackTrace) {
      debugPrint('VoiceWebRtcRsSession: failed to send audio frame: $error\n$stackTrace');
    }
  }

  /// Called by the voice connection controller when a Speaking event
  /// arrives, to learn which user a given SSRC belongs to - same role as
  /// [VoiceMediaSession.handleSpeaking].
  void handleSpeaking({required Snowflake userId, required int ssrc}) {
    _userIdBySsrc[ssrc] = userId;
    _participant(userId);
  }

  /// The local SSRC Discord assigned this connection - from
  /// [VoiceReady.ssrc], set by the connection controller once known (before
  /// that, DAVE codec assignment for outgoing frames is skipped - see
  /// [applyAnswer]).
  set localSsrc(int? ssrc) => _ssrc = ssrc;

  _RemoteParticipant _participant(Snowflake userId) => _participantsByUserId.putIfAbsent(
    userId,
    () => _RemoteParticipant(sampleRate: _sampleRate, channels: _channels),
  );

  String _buildFragment(String sdp) {
    final lines = sdp.split(RegExp(r'\r\n|\n'));
    final kept = lines.where(
      (line) => _fragmentAttributePattern.hasMatch(line) || _fragmentRtpmapPattern.hasMatch(line),
    );
    return kept.join('\r\n');
  }

  /// Pulls the `sdp` field back out of a `create_offer`/`local_description`
  /// JSON string (an `RTCSessionDescription`: `{"sdp_type":..., "sdp":...}`).
  String? _extractSdp(String? sessionDescriptionJson) {
    if (sessionDescriptionJson == null) return null;
    final match = RegExp(r'"sdp"\s*:\s*"((?:[^"\\]|\\.)*)"').firstMatch(sessionDescriptionJson);
    if (match == null) return null;
    // Reverse JSON string escaping (\n, \", \\) - cheaper than pulling in a
    // full JSON decode for one field, and this is already a fixed-shape
    // string we generated field names for on the Rust side.
    return match
        .group(1)!
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', '\\');
  }

  /// Wraps a bare SDP answer string into the JSON shape
  /// `RtcPeerConnection.setRemoteDescription` expects - an
  /// `RTCSessionDescription`, whose Rust struct has `#[serde(rename = "type")]`
  /// on its type field (so the JSON key is `"type"`, not `"sdp_type"` as the
  /// Rust field itself is named) and per-variant renames on `RTCSdpType`
  /// giving lowercase string values (`"offer"`/`"answer"`/`"pranswer"`).
  String _wrapAsAnswerJson(String sdp) {
    final escaped = sdp.replaceAll('\\', r'\\').replaceAll('"', r'\"').replaceAll('\r\n', r'\r\n').replaceAll('\n', r'\n');
    return '{"type":"answer","sdp":"$escaped"}';
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    await _micSubscription?.cancel();
    await _recorder?.dispose();
    _opusEncoder?.dispose();
    _encryptor?.dispose();
    await _ratchetSub?.cancel();
    await _eventsSub?.cancel();
    await _cameraController?.stopImageStream();

    for (final participant in _participantsByUserId.values) {
      participant.dispose();
    }
    _participantsByUserId.clear();
    _pendingTracksBySsrc.clear();
    _videoDecodersByUserId.clear();
    _videoProcessingChains.clear();
    await _remoteVideoFrameController.close();

    await _peerConnection?.close();
  }
}

class _RemoteParticipant {
  _RemoteParticipant({required int sampleRate, required int channels})
    : opusDecoder = opus.OpusDecoder(sampleRate: sampleRate, channels: channels),
      decryptor = dave.DaveDecryptor()..transitionToPassthroughMode(true),
      audioSource = SoLoud.instance.setBufferStream(
        sampleRate: sampleRate,
        channels: channels == 1 ? Channels.mono : Channels.stereo,
        format: BufferType.s16le,
        bufferingType: BufferingType.released,
        bufferingTimeNeeds: 0.1,
      ) {
    SoLoud.instance.play(audioSource);
  }

  final opus.OpusDecoder opusDecoder;
  final dave.DaveDecryptor decryptor;
  final AudioSource audioSource;

  bool _hasRatchet = false;
  int _receivedCount = 0;

  void dispose() {
    opusDecoder.dispose();
    decryptor.dispose();
    SoLoud.instance.disposeSource(audioSource);
  }
}
