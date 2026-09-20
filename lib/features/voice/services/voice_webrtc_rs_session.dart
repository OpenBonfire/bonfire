import 'dart:async';
import 'dart:collection';
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
// Fallback frame duration for the very first video frame sent, before
// there's a previous frame's timestamp to measure the real interval from -
// see _encodeAndSendLocalVideoFrame. 15fps is a reasonable nominal default;
// actual cadence is whatever the camera delivers, not fixed.
const _videoFrameDurationMicros = 1000000 ~/ 15;
// Leaves headroom below the real network MTU for DAVE's per-frame overhead
// (nonce, auth tag, small bookkeeping) plus SRTP's own overhead, both added
// after this - see RtcMediaSender.writePacketizedFrame's doc.
const _videoRtpMtu = 1000;
// Must match voice_video_overlay.dart's CameraMacOSView `resolution:`
// setting (PictureResolution.medium = 960x540) - reported to Discord via
// VoiceGateway.sendVideo's max_resolution field, which a real client always
// sends and which the server appears to need to treat a video stream as
// valid (see sendVideo's doc).
//
// Deliberately 16:9, not the also-available 4:3 PictureResolution.low
// (640x480): camera_macos's own capture session negotiates the camera's
// native format independently of this setting (via `.high` session
// preset), which for essentially every modern webcam is 16:9 - camera_macos
// then stretches that into whatever aspect ratio this constant asks for
// with independent (non-aspect-preserving) x/y scale factors, so a 4:3
// target visibly squishes the picture. 16:9 avoids the mismatch entirely.
const _videoCaptureWidth = 960;
const _videoCaptureHeight = 540;

/// Attribute lines kept when building the Select Protocol SDP fragment from
/// the local offer - per https://docs.discord.food/topics/voice-connections
/// verbatim: "Keep every line matching `^a=(extmap-allow-mixed|ice-|
/// fingerprint|extmap:)`. Keep only `a=rtpmap` lines for Opus, VP8, and the
/// RTX payload whose `apt` points at VP8." This is a fixed rule about the
/// fragment's *own* contents, independent of which video codec is actually
/// used for media - H264 (what this class actually sends/receives - see the
/// class doc) is a separate codec entirely from VP8, and its own rtpmap is
/// deliberately excluded from this fragment: "Other video codecs are still
/// advertised in the `codecs` field of Select Protocol when present in the
/// offer; their `a=rtpmap` lines are not included in this SDP fragment." See
/// [VoiceGateway.selectWebRtcProtocol]'s `codecs` array for where H264 is
/// actually communicated, and [_h264PayloadTypePattern]/
/// [videoPayloadType] for where its payload type comes from instead.
final _fragmentAttributePattern = RegExp(
  r'^a=(extmap-allow-mixed|ice-|fingerprint|extmap:)',
);
final _opusPayloadTypePattern = RegExp(
  r'^a=rtpmap:(\d+) opus/',
  caseSensitive: false,
);
final _vp8PayloadTypePattern = RegExp(
  r'^a=rtpmap:(\d+) vp8/',
  caseSensitive: false,
);
final _h264PayloadTypePattern = RegExp(
  r'^a=rtpmap:(\d+) h264/',
  caseSensitive: false,
);
final _rtxAptPattern = RegExp(r'^a=fmtp:(\d+) apt=(\d+)', caseSensitive: false);

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

/// The real-ICE/DTLS-SRTP WebRTC transport, built on `flutter_webrtc_rs`
/// (webrtc-rs bound via flutter_rust_bridge - see `packages/flutter_webrtc_rs`).
///
/// **Confirmed working against a live Discord voice server**, for both the
/// signaling shape and the media pipeline below it - see
/// https://docs.discord.food/topics/voice-connections, which this follows
/// deliberately closely rather than guessing:
///
/// - Video capability is negotiated exactly **once**, as part of the
///   *initial* offer/answer (a `m=video` section is always included,
///   whether or not the camera is on yet) - never via a second Select
///   Protocol/SDP exchange. That was tried first and is confirmed to crash
///   the voice server outright (gateway close code 4013, "WebRTC crashed"),
///   taking the whole call down, audio included. Real clients (per the
///   docs, and per how Discord's own UI behaves - a mid-call camera toggle
///   never re-shows a connecting spinner) negotiate video once and then
///   just flip it on/off - see [startLocalVideo]/[stopLocalVideo] and
///   [VoiceGateway.sendVideo] (opcode 12).
/// - The video SSRC/RTX-SSRC used are **the ones Discord's Ready payload
///   assigns** (see [VoiceReadyStream]), passed into
///   [createOfferAndBuildFragment] - not ones this class or webrtc-rs pick,
///   since the whole point of the upfront negotiation is that those values
///   are fixed for the call's lifetime.
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
  int? _videoSsrc;
  int? _videoRtxSsrc;
  int? _opusPayloadType;
  int? _videoPayloadType;
  int? _videoRtxPayloadType;

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
  DateTime? _lastVideoFrameSentAt;
  bool _loggedFirstCameraFrame = false;
  int _sentVideoFrameCount = 0;
  final Map<Snowflake, int> _receivedVideoFrameCounts = {};
  CameraMacOSController? _cameraController;
  final Map<Snowflake, H264Decoder> _videoDecodersByUserId = {};
  final Map<Snowflake, RtcH264Depacketizer> _videoDepacketizersByUserId = {};
  final Map<Snowflake, Future<void>> _videoProcessingChains = {};
  /// Accumulates depacketized (still-encrypted) bytes across one whole
  /// access unit per remote user, until the RTP marker bit says it's
  /// complete - see `_decodeRemoteVideoPacket`'s doc.
  final Map<Snowflake, BytesBuilder> _videoFrameAccumulators = {};
  final _remoteVideoFrameController =
      StreamController<RemoteVideoFrameEvent>.broadcast();

  /// Decoded video frames from remote participants - one event per decoded
  /// picture, tagged with which participant it came from. The UI layer owns
  /// turning these into pixels on screen (see `dart:ui`'s
  /// `decodeImageFromPixels` for the simplest path from [DecodedVideoFrame]'s
  /// RGB8 bytes to a paintable `ui.Image`).
  Stream<RemoteVideoFrameEvent> get onRemoteVideoFrame =>
      _remoteVideoFrameController.stream;

  bool _disposed = false;

  /// The payload type Discord's SFU should expect Opus RTP packets on - only
  /// meaningful after [createOfferAndBuildFragment] returns; pass to
  /// [VoiceGateway.selectWebRtcProtocol].
  int? get opusPayloadType => _opusPayloadType;

  /// As [opusPayloadType], for H264 - null if [createOfferAndBuildFragment]
  /// wasn't given a [VoiceReadyStream] to negotiate video against.
  int? get videoPayloadType => _videoPayloadType;

  /// The RTX (retransmission) payload type paired with [videoPayloadType],
  /// if webrtc-rs registered one for H264 (mirrors how it already does for
  /// VP8 - see the fragment log) - null if there's no pairing, or no video.
  /// Passed to [VoiceGateway.selectWebRtcProtocol]'s `codecs` array.
  int? get videoRtxPayloadType => _videoRtxPayloadType;

  /// Opens the peer connection, creates the local Opus sender (and, if
  /// [videoStream] is given, a video sender too - see the class doc on why
  /// this always happens up front rather than being added later), waits for
  /// ICE gathering to finish (Discord doesn't trickle ICE for this - the
  /// full candidate set must be embedded in the fragment), and returns the
  /// trimmed SDP fragment to send via [VoiceGateway.selectWebRtcProtocol].
  ///
  /// [videoStream] should be the `type: "video"` entry from
  /// [VoiceReady.streams] (present because Identify requested video - see
  /// `VoiceGateway._identify`) - its `ssrc`/`rtxSsrc` are what Discord
  /// expects this call's video to use for its entire lifetime.
  ///
  /// Must be called before [applyAnswer]. Unlike [VoiceMediaSession], there
  /// is no separate IP-discovery step - ICE candidate gathering replaces it.
  Future<String> createOfferAndBuildFragment({
    VoiceReadyStream? videoStream,
  }) async {
    final pc = await RtcPeerConnection.create(
      config: const RtcConfig(iceServers: [], udpBindAddrs: ['0.0.0.0:0']),
    );
    _peerConnection = pc;

    final gatherComplete = Completer<void>();
    _eventsSub = pc.events().listen(
      (event) => _handlePeerConnectionEvent(event, gatherComplete),
    );

    debugPrint('VoiceWebRtcRsSession: requesting microphone permission');
    final recorder = AudioRecorder();
    _recorder = recorder;
    if (!await recorder.hasPermission()) {
      throw const VoiceMicrophonePermissionDeniedException();
    }

    // Both added before creating the offer, so the *one* offer this call
    // ever makes already negotiates both m=audio and (if requested) m=video
    // sections - see the class doc for why there's no "add video later".
    _audioSender = await pc.addMediaSender(
      kind: MediaKind.audio,
      mimeType: 'audio/opus',
    );
    if (videoStream != null) {
      _videoSsrc = videoStream.ssrc;
      _videoRtxSsrc = videoStream.rtxSsrc;
      _videoSender = await pc.addMediaSender(
        kind: MediaKind.video,
        mimeType: 'video/H264',
        ssrc: videoStream.ssrc,
      );
    }

    final offer = await pc.createOffer();
    await pc.setLocalDescription(descriptionJson: offer);
    debugPrint(
      'VoiceWebRtcRsSession: local offer created, waiting for ICE gathering',
    );

    await gatherComplete.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () =>
          debugPrint('VoiceWebRtcRsSession: ICE gathering timed out after 10s'),
    );

    final sdp = _extractSdp(await pc.localDescription()) ?? '';
    _opusPayloadType = _firstGroupMatch(_opusPayloadTypePattern, sdp);
    _videoPayloadType = _firstGroupMatch(_h264PayloadTypePattern, sdp);
    _videoRtxPayloadType = _findRtxPayloadType(sdp, _videoPayloadType);
    final fragment = _buildFragment(sdp);
    debugPrint(
      'VoiceWebRtcRsSession: built fragment (opusPT=$_opusPayloadType videoPT=$_videoPayloadType '
      'videoRtxPT=$_videoRtxPayloadType):\n$fragment',
    );
    return fragment;
  }

  /// Starts local camera capture and begins encoding+sending on the video
  /// sender [createOfferAndBuildFragment] already negotiated, then announces
  /// it via [VoiceGateway.sendVideo] (opcode 12, `active: true`) - **not** a
  /// second SDP exchange (see class doc). Throws [StateError] if
  /// [createOfferAndBuildFragment] wasn't given a video stream to negotiate.
  ///
  /// Reuses the Ready-assigned SSRC for the whole connection's lifetime -
  /// an earlier version of this method switched to a freshly-generated SSRC
  /// here instead (misreading real client traffic that actually just showed
  /// `video_ssrc: 0`/empty `streams` for the inactive declaration vs. the
  /// real Ready SSRC for the active one, not two different real SSRCs). That
  /// was actively broken, not just unconfirmed: a reference implementation
  /// (github.com/Discord-RE/Discord-video-stream's `BaseMediaConnection`)
  /// never regenerates its video SSRC either, and this repo's own
  /// `RtcMediaSender::write_rtp` path was independently confirmed to
  /// **silently drop every packet** stamped with any SSRC other than the
  /// one baked into the sender's track at creation time (the underlying
  /// `rtc` crate's `RTCRtpSender::write_rtp` checks `sender.track().ssrcs()`
  /// and errors before any network I/O) - so every "active" video frame
  /// this method ever sent under the old SSRC never left the process.
  Future<void> startLocalVideo(CameraMacOSController controller) async {
    final ssrc = _ssrc;
    final sender = _videoSender;
    final videoSsrc = _videoSsrc;
    if (videoSsrc == null || sender == null) {
      throw StateError(
        'createOfferAndBuildFragment() was not given a video stream to negotiate - '
        'nothing to turn on. See class doc.',
      );
    }
    if (ssrc == null) {
      throw StateError(
        'localSsrc must be set (from VoiceReady.ssrc) before this',
      );
    }

    _cameraController = controller;
    _videoEncoder = await H264Encoder.create(bitrateBps: _videoBitrateBps);
    await controller.startImageStream(_handleCameraFrame);

    // Cross-check: the payload type our RTP packets actually carry (resolved
    // from webrtc-rs's own negotiated SDP state) must match what we told
    // Discord to expect in the codecs array (`_videoPayloadType`, parsed
    // independently from our own offer) - if they ever disagree, packets go
    // out under a payload type Discord was never told about and just get
    // silently dropped, with no error anywhere to notice by. Both are
    // expected to already be 102 from the same negotiation, but this is the
    // one thing in the whole pipeline we hadn't actually verified matches.
    final resolvedPayloadType = await sender.resolvedPayloadType();
    debugPrint(
      'VoiceWebRtcRsSession: video RTP payload type check: '
      'resolved=$resolvedPayloadType declaredToDiscord=$_videoPayloadType '
      '${resolvedPayloadType == _videoPayloadType ? '(match)' : '(MISMATCH!)'}',
    );

    gateway.sendVideo(
      audioSsrc: ssrc,
      videoSsrc: videoSsrc,
      rtxSsrc: _videoRtxSsrc,
      active: true,
      maxBitrateBps: _videoBitrateBps,
      maxWidth: _videoCaptureWidth,
      maxHeight: _videoCaptureHeight,
    );
    debugPrint(
      'VoiceWebRtcRsSession: local video started, announced via opcode 12 '
      '(audioSsrc=$ssrc videoSsrc=$videoSsrc, the Ready-assigned SSRC, unchanged)',
    );
  }

  /// Stops local camera capture and announces it via [VoiceGateway.sendVideo]
  /// (`active: false`) - the inverse of [startLocalVideo]. Safe to call even
  /// if video was never started.
  Future<void> stopLocalVideo() async {
    await _cameraController?.stopImageStream();
    _cameraController = null;
    _videoEncoder?.dispose();
    _videoEncoder = null;
    _lastVideoFrameSentAt = null;
    _loggedFirstCameraFrame = false;
    _sentVideoFrameCount = 0;

    final videoSsrc = _videoSsrc;
    final ssrc = _ssrc;
    if (videoSsrc != null && ssrc != null) {
      gateway.sendVideo(
        audioSsrc: ssrc,
        videoSsrc: videoSsrc,
        rtxSsrc: _videoRtxSsrc,
        active: false,
        maxBitrateBps: _videoBitrateBps,
        maxWidth: _videoCaptureWidth,
        maxHeight: _videoCaptureHeight,
      );
    }
    debugPrint('VoiceWebRtcRsSession: local video stopped');
  }

  void _handleCameraFrame(CameraImageData? image) {
    if (image == null) return;
    final encoder = _videoEncoder;
    final sender = _videoSender;
    if (encoder == null || sender == null) return;

    if (!_loggedFirstCameraFrame) {
      _loggedFirstCameraFrame = true;
      debugPrint(
        'VoiceWebRtcRsSession: first camera frame received '
        '(${image.width}x${image.height}, ${image.bytes.length}B, bytesPerRow=${image.bytesPerRow})',
      );
    }

    // camera_macos may pad each row to a stride wider than `width * 4` -
    // H264Encoder.encodeRgba8 expects tightly packed pixel data (no per-row
    // padding), so strip it here if present rather than pushing stride
    // handling into the Rust encoder for what's normally a no-op copy.
    //
    // Despite the field's name/doc, `image.bytes` is actually R,G,B,A, not
    // BGRA - see _encodeAndSendLocalVideoFrame's doc.
    final expectedRowBytes = image.width * 4;
    final Uint8List rgba;
    if (image.bytesPerRow == expectedRowBytes) {
      rgba = image.bytes;
    } else {
      rgba = Uint8List(expectedRowBytes * image.height);
      for (var row = 0; row < image.height; row++) {
        final srcOffset = row * image.bytesPerRow;
        rgba.setRange(
          row * expectedRowBytes,
          (row + 1) * expectedRowBytes,
          image.bytes.sublist(srcOffset, srcOffset + expectedRowBytes),
        );
      }
    }

    unawaited(
      _encodeAndSendLocalVideoFrame(encoder, rgba, image.width, image.height),
    );
  }

  /// Encodes one camera frame, then encrypts+packetizes+sends it - DAVE
  /// encrypts the **whole encoded access unit** in one call (SPS+PPS+IDR-
  /// slice together for a keyframe), not per-NAL and not per-RTP-payload
  /// fragment. Confirmed from Discord's own vendored `libdave` source
  /// (`ProcessFrameH264` in `codec_utils.cpp` loops over every NAL in the
  /// buffer it's given in one call, and `Encryptor::Encrypt` appends exactly
  /// one trailer per call) - encrypting at any finer granularity produces
  /// several independently-tagged ciphertexts a real peer's decryptor can
  /// never parse, even though it looks fine against this app's own loopback
  /// tests. See `RtcMediaSender.writePacketizedFrame`'s doc in `media.rs`
  /// for the full pipeline this now follows.
  Future<void> _encodeAndSendLocalVideoFrame(
    H264Encoder encoder,
    Uint8List rgba,
    int width,
    int height,
  ) async {
    final sender = _videoSender;
    final encryptor = _encryptor;
    final videoSsrc = _videoSsrc;
    if (sender == null) return;
    try {
      // Despite camera_macos's own naming (`CameraImageData`, doc comments
      // claiming BGRA8) and its capture session genuinely requesting
      // `kCVPixelFormatType_32BGRA`, the bytes it actually delivers over the
      // image-stream channel are R,G,B,A: internally it re-wraps the
      // captured frame in an `NSBitmapImageRep`, whose default in-memory
      // layout is alpha-last R,G,B,A, not the alpha-first BGRA the
      // `CGImage` was built with - a plugin-internal conversion, not
      // anything this app's own capture/stride code does. Encoding this as
      // BGRA swapped red and blue in every transmitted frame (very visible
      // on skin tones, which read close to solid blue when swapped).
      final encoded = await encoder.encodeRgba8(
        data: rgba,
        width: width,
        height: height,
      );
      if (encoded.isEmpty) return;

      // Same DAVE encrypt-or-passthrough pattern as _sendFrame's audio path
      // - required once DAVE activates (see applyAnswer's video codec
      // assignment doc) - applied once to the whole frame (see this
      // method's doc), not per NAL and not per RTP packet.
      Uint8List toSend = encoded;
      if (encryptor != null && videoSsrc != null) {
        final encryptResult = encryptor.encrypt(
          mediaType: dave.DAVEMediaType.DAVE_MEDIA_TYPE_VIDEO,
          ssrc: videoSsrc,
          frame: encoded,
        );
        if (!encryptResult.isSuccess) {
          debugPrint(
            'VoiceWebRtcRsSession: DAVE failed to encrypt a video frame '
            '(${encoded.length}B, code=${encryptResult.code}) - dropping it',
          );
          return;
        }
        toSend = encryptResult.frame;
      }

      // Duration is measured from the actual gap since the last frame
      // (whatever cadence the camera delivers at), falling back to a
      // nominal default only for the very first frame, when there's no
      // previous timestamp yet.
      final now = DateTime.now();
      final lastSent = _lastVideoFrameSentAt;
      final durationMicros = lastSent == null
          ? _videoFrameDurationMicros
          : now.difference(lastSent).inMicroseconds.clamp(1, 1000000);
      _lastVideoFrameSentAt = now;

      await sender.writePacketizedFrame(
        data: toSend,
        mtu: BigInt.from(_videoRtpMtu),
        durationMicros: BigInt.from(durationMicros),
      );

      _sentVideoFrameCount++;
      if (_sentVideoFrameCount <= 3 || _sentVideoFrameCount % 150 == 0) {
        debugPrint(
          'VoiceWebRtcRsSession: sent local video frame #$_sentVideoFrameCount '
          '(${encoded.length}B encoded, durationMicros=$durationMicros)',
        );
      }
    } catch (error, stackTrace) {
      debugPrint(
        'VoiceWebRtcRsSession: failed to encode/send local video frame: $error\n$stackTrace',
      );
    }
  }

  int? _firstGroupMatch(RegExp pattern, String sdp) {
    for (final line in sdp.split(RegExp(r'\r\n|\n'))) {
      final match = pattern.firstMatch(line);
      if (match != null) return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Finds the RTX payload type paired with [forPayloadType] by cross-
  /// referencing `a=fmtp:<rtx_pt> apt=<pt>` lines - RTX's own rtpmap doesn't
  /// name the codec it retransmits (`a=rtpmap:97 rtx/90000` looks the same
  /// regardless of whether it's pairing with H264, VP8, or anything else),
  /// so the `apt` cross-reference is the only way to find the right one.
  /// Returns null if [forPayloadType] is null or has no RTX pairing.
  int? _findRtxPayloadType(String sdp, int? forPayloadType) {
    if (forPayloadType == null) return null;
    for (final line in sdp.split(RegExp(r'\r\n|\n'))) {
      final match = _rtxAptPattern.firstMatch(line);
      if (match != null && match.group(2) == forPayloadType.toString()) {
        return int.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  /// Applies the SFU's SDP answer, received via
  /// [VoiceGateway.onSessionDescription]'s [VoiceSessionDescription.sdp],
  /// and starts mic capture. Once this returns, outgoing audio is flowing
  /// (DAVE-encrypted once ratchets arrive, plain Opus until then) and
  /// incoming tracks will start surfacing via [handleSpeaking] pairing with
  /// [PeerConnectionEvent_RemoteTrack] events. Called exactly once per call
  /// (there is no renegotiation - see class doc).
  Future<void> applyAnswer(String sdp) async {
    final pc = _peerConnection;
    if (pc == null) {
      throw StateError(
        'createOfferAndBuildFragment() must be called before this',
      );
    }

    debugPrint('VoiceWebRtcRsSession: raw answer sdp from Discord:\n$sdp');

    // Per https://docs.discord.food/topics/voice-connections, Discord's `sdp`
    // here is NOT a standards-compliant SDP a real WebRTC stack can apply
    // directly - its `m=` line's proto is a custom `ICE/SDP` token (not
    // `UDP/TLS/RTP/SAVPF`), which is exactly what made webrtc-rs's parser
    // reject it outright. The client is expected to *extract* specific
    // fields from it (DTLS fingerprint, ICE ufrag/pwd, candidates,
    // connection address) and *synthesize its own* standards-compliant
    // answer using those - see `_synthesizeAnswerSdp`.
    await pc.setRemoteDescription(
      descriptionJson: _wrapAsAnswerJson(_synthesizeAnswerSdp(sdp)),
    );

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
    // Without this, once DAVE activates, video frames go out unencrypted
    // while every real Discord client on the other end expects DAVE-
    // encrypted video - they can't do anything useful with what we send,
    // which is why nothing ever showed up as "live" despite frames
    // genuinely leaving this machine (confirmed via encoder.cpp's own
    // "Encrypted audio: N, video: 0" log line).
    final videoSsrc = _videoSsrc;
    if (videoSsrc != null) {
      encryptor.assignSsrcToCodec(videoSsrc, dave.DAVECodec.DAVE_CODEC_H264);
    }
    _encryptor = encryptor;

    _ratchetSub = daveSession?.onRatchetUpdate.listen(_handleRatchetUpdate);
    final known = daveSession?.knownRatchets;
    if (known != null) {
      for (final entry in known.entries) {
        _handleRatchetUpdate(
          DaveRatchetUpdate(
            userId: entry.key,
            ratchet: entry.value,
            isSelf: entry.key == selfUserId,
          ),
        );
      }
    }

    _opusEncoder = opus.OpusEncoder(
      sampleRate: _sampleRate,
      channels: _channels,
    );
    final micStream = await _recorder!.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: _channels,
      ),
    );
    _micSubscription = micStream.listen(_handleMicData);

    // A real client sends this immediately on connecting, camera off,
    // before the user ever turns it on - confirmed live from the web
    // client's own socket traffic. We only ever sent opcode 12 when the
    // user actually opened the camera, never this upfront declaration -
    // if Discord's server uses it to register the video SSRC against this
    // participant before accepting an `active: true` for that same SSRC
    // later, skipping it could mean the later activation lands on an SSRC
    // the server never associated with us in the first place.
    if (videoSsrc != null && ssrc != null) {
      gateway.sendVideo(
        audioSsrc: ssrc,
        videoSsrc: videoSsrc,
        rtxSsrc: _videoRtxSsrc,
        active: false,
        maxBitrateBps: _videoBitrateBps,
        maxWidth: _videoCaptureWidth,
        maxHeight: _videoCaptureHeight,
      );
    }

    debugPrint('VoiceWebRtcRsSession: started (dave=${daveSession != null})');
  }

  void _handleRatchetUpdate(DaveRatchetUpdate update) {
    if (update.isSelf) {
      _encryptor!.setKeyRatchet(update.ratchet);
      _encryptor!.passthroughMode = false;
      debugPrint(
        '[VoiceDave/rtc] self key ratchet updated, DAVE encryption active',
      );
    } else {
      _participant(
        update.userId,
      ).decryptor.transitionToKeyRatchet(update.ratchet);
      _participant(update.userId).decryptor.transitionToPassthroughMode(false);
      _participant(update.userId)._hasRatchet = true;
      debugPrint('[VoiceDave/rtc] key ratchet updated for ${update.userId}');
    }
  }

  void _handlePeerConnectionEvent(
    PeerConnectionEvent event,
    Completer<void> gatherComplete,
  ) {
    switch (event) {
      case PeerConnectionEvent_IceGatheringStateChanged(:final field0):
        if (field0 == IceGatheringState.complete &&
            !gatherComplete.isCompleted) {
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
    // Video uses rawPackets() (undepacketized, one event per RTP packet) so
    // depacketization can run on the still-encrypted wire bytes, with DAVE
    // decryption happening only after a complete NAL comes out the other
    // side - see _decodeRemoteVideoPacket and RtcH264Depacketizer's doc.
    // Audio keeps using packets() since Opus never needs this distinction
    // (one Opus frame is always exactly one RTP packet, so depacketizing
    // and decrypting are the same granularity either way).
    final packets = kind == MediaKind.video
        ? track.rawPackets()
        : track.packets();
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

  Future<void> _waitForSsrcThenReceive(
    int ssrc,
    MediaKind kind,
    Stream<RemoteRtpPacket> packets,
  ) async {
    while (!_disposed && !_userIdBySsrc.containsKey(ssrc)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (_disposed) return;
    final userId = _userIdBySsrc[ssrc];
    if (userId == null) return;
    _pendingTracksBySsrc.remove(ssrc);
    packets.listen((packet) => _routeRemotePacket(userId, kind, packet));
  }

  void _startReceiving(
    Snowflake userId,
    MediaKind kind,
    RemoteRtpPacket firstPacket,
    Stream<RemoteRtpPacket> packets,
  ) {
    _routeRemotePacket(userId, kind, firstPacket);
    packets.listen((packet) => _routeRemotePacket(userId, kind, packet));
  }

  void _routeRemotePacket(
    Snowflake userId,
    MediaKind kind,
    RemoteRtpPacket packet,
  ) {
    if (kind == MediaKind.video) {
      // Chained rather than fire-and-forget: the H264 decoder is stateful
      // and must see packets in arrival order (it reassembles reference
      // frames across calls) - awaiting each `decode()` before starting the
      // next preserves that even though decode is an async FRB call, at the
      // cost of decode work never running concurrently with itself for one
      // participant (fine; it's already serialized by a Mutex on the Rust
      // side, so this isn't giving up real parallelism).
      final previous = _videoProcessingChains[userId] ?? Future<void>.value();
      _videoProcessingChains[userId] = previous.then(
        (_) => _decodeRemoteVideoPacket(userId, packet),
      );
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

  Future<RtcH264Depacketizer> _videoDepacketizerFor(Snowflake userId) async {
    final existing = _videoDepacketizersByUserId[userId];
    if (existing != null) return existing;
    final depacketizer = await RtcH264Depacketizer.create();
    _videoDepacketizersByUserId[userId] = depacketizer;
    return depacketizer;
  }

  /// `packet` here is one **raw, undepacketized, still-encrypted** RTP
  /// packet (from [RtcRemoteTrack.rawPackets]) - depacketize-then-decrypt,
  /// in that order, mirroring the send side's whole-access-unit encryption
  /// (see `_encodeAndSendLocalVideoFrame`'s doc and `RtcH264Depacketizer`'s
  /// doc in `media.rs`). Reassembly (FU-A/STAP-A) is pure RTP framing and
  /// needs no decryption first; DAVE needs the *whole access unit* per call
  /// (confirmed from Discord's own `libdave` source - see this class's other
  /// video docs), which can span more than one depacketized chunk (an
  /// SPS+PPS STAP-A plus a separately-fragmented slice, say), so results are
  /// accumulated per user until the RTP marker bit says the access unit is
  /// complete, and only then decrypted, once, as a whole.
  Future<void> _decodeRemoteVideoPacket(
    Snowflake userId,
    RemoteRtpPacket packet,
  ) async {
    try {
      final depacketizer = await _videoDepacketizerFor(userId);
      final depacketized = await depacketizer.depacketize(data: packet.payload);
      if (depacketized.isNotEmpty) {
        (_videoFrameAccumulators[userId] ??= BytesBuilder(copy: false)).add(depacketized);
      }
      if (!packet.marker) return; // access unit not complete yet

      final accumulator = _videoFrameAccumulators.remove(userId);
      final encryptedFrame = accumulator?.toBytes();
      if (encryptedFrame == null || encryptedFrame.isEmpty) return;

      final participant = _participant(userId);
      final decryptResult = participant.decryptor.decrypt(
        mediaType: dave.DAVEMediaType.DAVE_MEDIA_TYPE_VIDEO,
        encryptedFrame: encryptedFrame,
      );
      if (!decryptResult.isSuccess) {
        debugPrint(
          'VoiceWebRtcRsSession: DAVE failed to decrypt a video frame from $userId '
          '(${encryptedFrame.length}B, code=${decryptResult.code}) - dropping',
        );
        return;
      }

      final decoder = await _videoDecoderFor(userId);
      final frame = await decoder.decode(data: decryptResult.frame);
      if (frame != null && !_disposed) {
        final count = (_receivedVideoFrameCounts[userId] ?? 0) + 1;
        _receivedVideoFrameCounts[userId] = count;
        if (count <= 3 || count % 150 == 0) {
          debugPrint(
            'VoiceWebRtcRsSession: decoded remote video frame #$count from $userId '
            '(${frame.width}x${frame.height})',
          );
        }
        _remoteVideoFrameController.add(
          RemoteVideoFrameEvent(userId: userId, frame: frame),
        );
      }
    } catch (error, stackTrace) {
      // Drop any partial accumulation for this user so a malformed/lost
      // fragment doesn't corrupt the start of the *next* access unit.
      _videoFrameAccumulators.remove(userId);
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

      final pcm = participant.opusDecoder.decode(
        opusFrame,
        frameSize: _samplesPerFrame,
      );
      SoLoud.instance.addAudioDataStream(
        participant.audioSource,
        pcm.buffer.asUint8List(),
      );
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
      final frame = Uint8List.sublistView(
        buffered,
        offset,
        offset + _bytesPerFrame,
      );
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
      final davePayload = encryptResult.isSuccess
          ? encryptResult.frame
          : opusFrame;

      await sender.writeEncodedFrame(
        data: davePayload,
        durationMicros: BigInt.from(_frameDurationMicros),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'VoiceWebRtcRsSession: failed to send audio frame: $error\n$stackTrace',
      );
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

  _RemoteParticipant _participant(Snowflake userId) =>
      _participantsByUserId.putIfAbsent(
        userId,
        () => _RemoteParticipant(sampleRate: _sampleRate, channels: _channels),
      );

  /// Builds the Select Protocol fragment per the exact rule quoted on
  /// [_fragmentAttributePattern]'s doc: the attribute pattern, plus
  /// `a=rtpmap` for Opus/VP8 only, plus the one RTX `a=rtpmap` whose
  /// `a=fmtp:<rtx_pt> apt=<pt>` points at the VP8 payload type found above
  /// (RTX's own rtpmap doesn't say "vp8" anywhere in it - `a=rtpmap:97
  /// rtx/90000` - so it can't be matched by mime type alone; the apt
  /// cross-reference is the only way to know which rtx payload, if any,
  /// belongs to VP8 rather than some other codec's retransmission stream).
  String _buildFragment(String sdp) {
    final lines = sdp.split(RegExp(r'\r\n|\n'));

    final vp8PayloadType = _firstGroupMatch(_vp8PayloadTypePattern, sdp);
    final vp8RtxPayloadType = _findRtxPayloadType(sdp, vp8PayloadType);

    bool isKeptRtpmap(String line) {
      final match = RegExp(
        r'^a=rtpmap:(\d+) ',
        caseSensitive: false,
      ).firstMatch(line);
      if (match == null) return false;
      final payloadType = int.tryParse(match.group(1)!);
      return payloadType != null &&
          (payloadType == _opusPayloadType ||
              payloadType == vp8PayloadType ||
              payloadType == vp8RtxPayloadType);
    }

    final kept = lines.where(
      (line) => _fragmentAttributePattern.hasMatch(line) || isKeptRtpmap(line),
    );
    // Per the docs' own algorithm: "Remove duplicates" is an explicit step,
    // not an afterthought - confirmed by a real client's own fragment
    // (captured live) having each ice-ufrag/ice-pwd/extmap line exactly
    // once. This was missing entirely: BUNDLE means ICE ufrag/pwd and
    // extmap lines are identical across every m= section in the local
    // offer, so a flat per-line filter over the whole SDP (audio section
    // *and* video section) kept every one of them twice - confirmed in
    // every fragment logged so far (`a=ice-ufrag:...`, `a=ice-pwd:...`,
    // `a=extmap:4 ...` each appearing twice). `LinkedHashSet` preserves
    // first-occurrence order while dropping the repeats.
    return LinkedHashSet<String>.from(kept).join('\r\n');
  }

  /// Pulls the `sdp` field back out of a `create_offer`/`local_description`
  /// JSON string (an `RTCSessionDescription`: `{"type":..., "sdp":...}`).
  String? _extractSdp(String? sessionDescriptionJson) {
    if (sessionDescriptionJson == null) return null;
    final match = RegExp(
      r'"sdp"\s*:\s*"((?:[^"\\]|\\.)*)"',
    ).firstMatch(sessionDescriptionJson);
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

  /// Synthesizes a standards-compliant SDP answer from Discord's raw
  /// (non-standard) `sdp` field, per
  /// https://docs.discord.food/topics/voice-connections: "the client must
  /// synthesize a complete browser-compatible answer" from the server's
  /// `sdp`, the negotiated codecs, the local offer's own payload types, and
  /// known remote SSRCs. This does the SDP-construction half of that -
  /// extracting the DTLS fingerprint, ICE ufrag/pwd, ICE candidate(s), and
  /// connection address out of Discord's fragment, then building a real
  /// `m=audio .../UDP/TLS/RTP/SAVPF ...` section (`a=setup:passive`, per the
  /// docs' own example) around them, reusing *our own* offer's payload
  /// types (`_opusPayloadType`/`_videoPayloadType`) rather than Discord's -
  /// the docs are explicit that payload types must match what we offered,
  /// not get remapped.
  ///
  /// Video is only included if `_videoPayloadType` is non-null, i.e. only if
  /// [createOfferAndBuildFragment] negotiated it.
  ///
  /// Throws [FormatException] if a required field is missing from Discord's
  /// fragment - that's a real signal something about the wire format
  /// assumption here is wrong, not something to silently paper over.
  String _synthesizeAnswerSdp(String discordSdp) {
    final fingerprint = _firstLineMatch(
      discordSdp,
      RegExp(r'^a=fingerprint:(.+)$', multiLine: true),
    );
    final iceUfrag = _firstLineMatch(
      discordSdp,
      RegExp(r'^a=ice-ufrag:(.+)$', multiLine: true),
    );
    final icePwd = _firstLineMatch(
      discordSdp,
      RegExp(r'^a=ice-pwd:(.+)$', multiLine: true),
    );
    final candidates = RegExp(
      r'^a=candidate:.+$',
      multiLine: true,
    ).allMatches(discordSdp).map((m) => m.group(0)!).toList();
    final connectionAddress =
        _firstLineMatch(
          discordSdp,
          RegExp(r'^c=IN IP4 (\S+)', multiLine: true),
        ) ??
        '0.0.0.0';

    if (fingerprint == null ||
        iceUfrag == null ||
        icePwd == null ||
        candidates.isEmpty) {
      throw FormatException(
        'Discord answer sdp is missing a required field for answer synthesis '
        '(fingerprint=$fingerprint, iceUfrag=$iceUfrag, icePwd=$icePwd, '
        'candidates=${candidates.length}) - raw sdp logged above in applyAnswer',
      );
    }

    String mediaSection({
      required String kind,
      required String mid,
      required List<int> payloadTypes,
      required List<String> rtpmapLines,
      required List<String> extraAttributes,
    }) {
      // RFC 4566 requires CRLF line endings - `StringBuffer.writeln` uses a
      // bare `\n`, so this joins explicitly rather than using it, to avoid
      // handing webrtc-rs's SDP parser a new way to be strict about this.
      final lines = [
        'm=$kind 9 UDP/TLS/RTP/SAVPF ${payloadTypes.join(' ')}',
        'c=IN IP4 $connectionAddress',
        'a=rtcp:9 IN IP4 $connectionAddress',
        'a=ice-ufrag:$iceUfrag',
        'a=ice-pwd:$icePwd',
        'a=fingerprint:$fingerprint',
        'a=setup:passive',
        'a=mid:$mid',
        'a=sendrecv',
        'a=rtcp-mux',
        ...rtpmapLines,
        ...extraAttributes,
        ...candidates,
        'a=end-of-candidates',
      ];
      return '${lines.join('\r\n')}\r\n';
    }

    final mids = <String>[];
    final sections = StringBuffer();

    // Computed before the audio section, since audio's `usedtx` depends on
    // whether video is negotiated at all - per the docs: "usedtx is 0 when
    // the local client is sending video and 1 otherwise."
    final videoPt = _videoPayloadType;

    final opusPt = _opusPayloadType;
    if (opusPt != null) {
      mids.add('0');
      sections.write(
        mediaSection(
          kind: 'audio',
          mid: '0',
          payloadTypes: [opusPt],
          rtpmapLines: ['a=rtpmap:$opusPt opus/48000/2'],
          extraAttributes: [
            'a=fmtp:$opusPt minptime=10;useinbandfec=1;usedtx=${videoPt != null ? 0 : 1}',
            'a=maxptime:60',
            'a=rtcp-fb:$opusPt transport-cc',
          ],
        ),
      );
    }

    if (videoPt != null) {
      final mid = mids.length.toString();
      mids.add(mid);
      final rtxPt = _videoRtxPayloadType;
      // x-google-max-bitrate is in kbps; _videoBitrateBps is the same target
      // passed to H264Encoder.create, so this just re-expresses it here.
      final maxBitrateKbps = _videoBitrateBps ~/ 1000;
      sections.write(
        mediaSection(
          kind: 'video',
          mid: mid,
          payloadTypes: [videoPt, if (rtxPt != null) rtxPt],
          rtpmapLines: [
            'a=rtpmap:$videoPt H264/90000',
            if (rtxPt != null) 'a=rtpmap:$rtxPt rtx/90000',
          ],
          extraAttributes: [
            // level-asymmetry-allowed/packetization-mode/profile-level-id are
            // H264-specific, required per the docs' "Answer Video Media
            // Sections" table; x-google-max-bitrate applies to any video
            // codec.
            'a=fmtp:$videoPt level-asymmetry-allowed=1;packetization-mode=1;'
                'profile-level-id=42e01f;x-google-max-bitrate=$maxBitrateKbps',
            if (rtxPt != null) 'a=fmtp:$rtxPt apt=$videoPt',
            'a=rtcp-fb:$videoPt ccm fir',
            'a=rtcp-fb:$videoPt nack',
            'a=rtcp-fb:$videoPt nack pli',
            'a=rtcp-fb:$videoPt goog-remb',
            'a=rtcp-fb:$videoPt transport-cc',
          ],
        ),
      );
    }

    return 'v=0\r\n'
        'o=- 0 0 IN IP4 127.0.0.1\r\n'
        's=-\r\n'
        't=0 0\r\n'
        'a=group:BUNDLE ${mids.join(' ')}\r\n'
        '$sections';
  }

  String? _firstLineMatch(String sdp, RegExp pattern) =>
      pattern.firstMatch(sdp)?.group(1)?.trim();

  /// Wraps a bare SDP answer string into the JSON shape
  /// `RtcPeerConnection.setRemoteDescription` expects - an
  /// `RTCSessionDescription`, whose Rust struct has `#[serde(rename = "type")]`
  /// on its type field (so the JSON key is `"type"`, not `"sdp_type"` as the
  /// Rust field itself is named) and per-variant renames on `RTCSdpType`
  /// giving lowercase string values (`"offer"`/`"answer"`/`"pranswer"`).
  String _wrapAsAnswerJson(String sdp) {
    final escaped = sdp
        .replaceAll('\\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\r\n', r'\r\n')
        .replaceAll('\n', r'\n');
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
    _videoDepacketizersByUserId.clear();
    _videoProcessingChains.clear();
    _videoFrameAccumulators.clear();
    await _remoteVideoFrameController.close();

    await _peerConnection?.close();
  }
}

class _RemoteParticipant {
  _RemoteParticipant({required int sampleRate, required int channels})
    : opusDecoder = opus.OpusDecoder(
        sampleRate: sampleRate,
        channels: channels,
      ),
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
