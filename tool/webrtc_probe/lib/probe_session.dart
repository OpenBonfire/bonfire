import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:dave/dave.dart' as dave;
import 'package:firebridge/firebridge.dart';
import 'package:flutter_webrtc_rs/flutter_webrtc_rs.dart';
import 'package:opus/opus.dart' as opus;

import 'dave_voice_session.dart';
import 'voice_gateway.dart';

const _sampleRate = 48000;
const _channels = 1;
const _samplesPerFrame = 960; // 20ms at 48kHz
const _frameDurationMicros = 20000;
const _videoBitrateBps = 1_000_000;
const _videoFrameDurationMicros = 1000000 ~/ 15;
const _videoRtpMtu = 1000;
const _videoCaptureWidth = 640;
const _videoCaptureHeight = 480;

final _fragmentAttributePattern = RegExp(
  r'^a=(extmap-allow-mixed|ice-|fingerprint|extmap:)',
);
final _opusPayloadTypePattern = RegExp(r'^a=rtpmap:(\d+) opus/', caseSensitive: false);
final _vp8PayloadTypePattern = RegExp(r'^a=rtpmap:(\d+) vp8/', caseSensitive: false);
final _h264PayloadTypePattern = RegExp(r'^a=rtpmap:(\d+) h264/', caseSensitive: false);
final _rtxAptPattern = RegExp(r'^a=fmtp:(\d+) apt=(\d+)', caseSensitive: false);

/// Every finding this probe cares about, for [ProbeVoiceSession.summary]'s
/// final report - the whole point of this harness is a machine-readable
/// pass/fail summary at the end, not a stream of logs to eyeball.
class ProbeSummary {
  bool webrtcConnected = false;
  bool daveActive = false;
  bool payloadTypeMatch = false;
  bool selfVideoAcked = false;
  int audioFramesSent = 0;
  int videoFramesSent = 0;
  int videoEncryptFailures = 0;
  int audioPacketsReceived = 0;
  int videoFramesDecoded = 0;
  int videoDecryptFailures = 0;
  final receivedVideoFromUserIds = <Snowflake>{};

  @override
  String toString() =>
      'ProbeSummary('
      'webrtcConnected=$webrtcConnected, '
      'daveActive=$daveActive, '
      'payloadTypeMatch=$payloadTypeMatch, '
      'selfVideoAcked=$selfVideoAcked, '
      'audioFramesSent=$audioFramesSent, '
      'videoFramesSent=$videoFramesSent, '
      'videoEncryptFailures=$videoEncryptFailures, '
      'audioPacketsReceived=$audioPacketsReceived, '
      'videoFramesDecoded=$videoFramesDecoded, '
      'videoDecryptFailures=$videoDecryptFailures, '
      'receivedVideoFromUserIds=$receivedVideoFromUserIds)';
}

/// [VoiceWebRtcRsSession] with camera/mic/speaker replaced by synthetic
/// generation, so it needs no real hardware and no Flutter plugins beyond
/// what's already required (camera_macos/record/flutter_soloud are
/// deliberately not dependencies of this probe app at all) - otherwise the
/// exact same signaling/WebRTC/DAVE pipeline as the real app, kept in sync
/// by hand since this is a debug tool, not shared production code.
class ProbeVoiceSession {
  ProbeVoiceSession({
    required this.gateway,
    required this.selfUserId,
    required this.daveSession,
    required this.log,
  });

  final VoiceGateway gateway;
  final Snowflake selfUserId;
  final DaveVoiceSession daveSession;
  final void Function(String) log;
  final summary = ProbeSummary();

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
  final Map<int, RtcRemoteTrack> _pendingTracksBySsrc = {};

  opus.OpusEncoder? _opusEncoder;
  Timer? _audioTimer;

  H264Encoder? _videoEncoder;
  Timer? _videoTimer;
  int _syntheticFrameCounter = 0;
  DateTime? _lastVideoFrameSentAt;
  final Map<Snowflake, H264Decoder> _videoDecodersByUserId = {};
  final Map<Snowflake, RtcH264Depacketizer> _videoDepacketizersByUserId = {};
  final Map<Snowflake, Future<void>> _videoProcessingChains = {};
  final Map<Snowflake, BytesBuilder> _videoFrameAccumulators = {};

  bool _disposed = false;

  int? get videoPayloadType => _videoPayloadType;
  int? get videoRtxPayloadType => _videoRtxPayloadType;

  int? get localSsrc => _ssrc;
  set localSsrc(int? ssrc) => _ssrc = ssrc;

  Future<String> createOfferAndBuildFragment({VoiceReadyStream? videoStream}) async {
    final pc = await RtcPeerConnection.create(
      config: const RtcConfig(iceServers: [], udpBindAddrs: ['0.0.0.0:0']),
    );
    _peerConnection = pc;

    final gatherComplete = Completer<void>();
    _eventsSub = pc.events().listen((event) => _handlePeerConnectionEvent(event, gatherComplete));

    _audioSender = await pc.addMediaSender(kind: MediaKind.audio, mimeType: 'audio/opus');
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
    log('local offer created, waiting for ICE gathering');

    await gatherComplete.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => log('ICE gathering timed out after 10s'),
    );

    final sdp = _extractSdp(await pc.localDescription()) ?? '';
    _opusPayloadType = _firstGroupMatch(_opusPayloadTypePattern, sdp);
    _videoPayloadType = _firstGroupMatch(_h264PayloadTypePattern, sdp);
    _videoRtxPayloadType = _findRtxPayloadType(sdp, _videoPayloadType);
    final fragment = _buildFragment(sdp);
    log('built fragment (opusPT=$_opusPayloadType videoPT=$_videoPayloadType videoRtxPT=$_videoRtxPayloadType)');
    return fragment;
  }

  int? get opusPayloadType => _opusPayloadType;

  Future<void> applyAnswer(String sdp) async {
    final pc = _peerConnection;
    if (pc == null) throw StateError('createOfferAndBuildFragment() must be called before this');

    await pc.setRemoteDescription(descriptionJson: _wrapAsAnswerJson(_synthesizeAnswerSdp(sdp)));

    final encryptor = dave.DaveEncryptor()..passthroughMode = true;
    final ssrc = _ssrc;
    if (ssrc != null) encryptor.assignSsrcToCodec(ssrc, dave.DAVECodec.DAVE_CODEC_OPUS);
    final videoSsrc = _videoSsrc;
    if (videoSsrc != null) encryptor.assignSsrcToCodec(videoSsrc, dave.DAVECodec.DAVE_CODEC_H264);
    _encryptor = encryptor;

    _ratchetSub = daveSession.onRatchetUpdate.listen(handleDaveRatchetUpdate);
    for (final entry in daveSession.knownRatchets.entries) {
      handleDaveRatchetUpdate(
        DaveRatchetUpdate(userId: entry.key, ratchet: entry.value, isSelf: entry.key == selfUserId),
      );
    }

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

    log('started (video sender present: ${_videoSender != null})');
  }

  /// Cross-checks the resolved payload type and reports into [summary].
  Future<void> checkPayloadType() async {
    final sender = _videoSender;
    if (sender == null) return;
    final resolved = await sender.resolvedPayloadType();
    summary.payloadTypeMatch = resolved == _videoPayloadType;
    log('video RTP payload type check: resolved=$resolved declaredToDiscord=$_videoPayloadType '
        '${summary.payloadTypeMatch ? '(match)' : '(MISMATCH!)'}');
  }

  void handleDaveRatchetUpdate(DaveRatchetUpdate update) {
    if (update.isSelf) {
      _encryptor!.setKeyRatchet(update.ratchet);
      _encryptor!.passthroughMode = false;
      summary.daveActive = true;
      log('self key ratchet updated, DAVE encryption active');
    } else {
      _participant(update.userId).decryptor.transitionToKeyRatchet(update.ratchet);
      _participant(update.userId).decryptor.transitionToPassthroughMode(false);
      log('key ratchet updated for ${update.userId}');
    }
  }

  /// Starts sending a synthetic (solid, slowly-cycling color) video frame on
  /// a timer, exactly as if a real camera were feeding frames at ~15fps -
  /// no camera_macos dependency needed. Reuses the Ready-assigned SSRC for
  /// the whole connection's lifetime - see the main app's
  /// VoiceWebRtcRsSession.startLocalVideo doc for why generating a fresh one
  /// here (an earlier version of this method did) is actively broken: the
  /// underlying `rtc` crate's sender silently drops every packet stamped
  /// with an SSRC other than the one baked into the track at creation time.
  Future<void> startSyntheticVideo() async {
    final ssrc = _ssrc;
    final sender = _videoSender;
    final videoSsrc = _videoSsrc;
    if (videoSsrc == null || sender == null || ssrc == null) {
      throw StateError('video was not negotiated - nothing to start');
    }

    _videoEncoder = await H264Encoder.create(bitrateBps: _videoBitrateBps);
    _videoTimer = Timer.periodic(const Duration(milliseconds: 66), (_) {
      unawaited(_encodeAndSendSyntheticVideoFrame());
    });

    gateway.sendVideo(
      audioSsrc: ssrc,
      videoSsrc: videoSsrc,
      rtxSsrc: _videoRtxSsrc,
      active: true,
      maxBitrateBps: _videoBitrateBps,
      maxWidth: _videoCaptureWidth,
      maxHeight: _videoCaptureHeight,
    );
    log('synthetic video started, announced via opcode 12 (videoSsrc=$videoSsrc, the Ready-assigned SSRC, unchanged)');
  }

  Uint8List _generateSyntheticBgraFrame(int counter) {
    final data = Uint8List(_videoCaptureWidth * _videoCaptureHeight * 4);
    final r = (counter * 3) % 256;
    for (var i = 0; i < data.length; i += 4) {
      data[i] = 180; // B
      data[i + 1] = 60; // G
      data[i + 2] = r; // R
      data[i + 3] = 255; // A
    }
    return data;
  }

  Future<void> _encodeAndSendSyntheticVideoFrame() async {
    if (_disposed) return;
    final encoder = _videoEncoder;
    final sender = _videoSender;
    final encryptor = _encryptor;
    final videoSsrc = _videoSsrc;
    if (encoder == null || sender == null) return;
    try {
      _syntheticFrameCounter++;
      final bgra = _generateSyntheticBgraFrame(_syntheticFrameCounter);
      final encoded = await encoder.encodeBgra8(
        data: bgra,
        width: _videoCaptureWidth,
        height: _videoCaptureHeight,
      );
      if (encoded.isEmpty || _disposed) return;

      // DAVE encrypts the whole access unit in one call (not per-NAL, not
      // per-RTP-fragment) - see media.rs's module doc and
      // VoiceWebRtcRsSession._encodeAndSendLocalVideoFrame's doc in the main
      // app for why.
      Uint8List toSend = encoded;
      if (encryptor != null && videoSsrc != null) {
        final encryptResult = encryptor.encrypt(
          mediaType: dave.DAVEMediaType.DAVE_MEDIA_TYPE_VIDEO,
          ssrc: videoSsrc,
          frame: encoded,
        );
        if (!encryptResult.isSuccess) {
          summary.videoEncryptFailures++;
          log('DAVE failed to encrypt a video frame (${encoded.length}B, code=${encryptResult.code}) - dropping it');
          return;
        }
        toSend = encryptResult.frame;
      }

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

      summary.videoFramesSent++;
      if (summary.videoFramesSent <= 3 || summary.videoFramesSent % 150 == 0) {
        log('sent synthetic video frame #${summary.videoFramesSent} (${encoded.length}B)');
      }
    } catch (error, stackTrace) {
      log('failed to encode/send synthetic video frame: $error\n$stackTrace');
    }
  }

  /// Starts sending silent Opus frames on a 20ms timer - no real mic
  /// (record package) needed, just enough to exercise the same audio path
  /// a real call always negotiates alongside video.
  void startSyntheticAudio() {
    _opusEncoder = opus.OpusEncoder(sampleRate: _sampleRate, channels: _channels);
    _audioTimer = Timer.periodic(const Duration(microseconds: _frameDurationMicros), (_) {
      unawaited(_sendSilentAudioFrame());
    });
  }

  Future<void> _sendSilentAudioFrame() async {
    final encoder = _opusEncoder;
    final encryptor = _encryptor;
    final sender = _audioSender;
    final ssrc = _ssrc;
    if (encoder == null || encryptor == null || sender == null) return;
    try {
      final silence = Int16List(_samplesPerFrame);
      final opusFrame = encoder.encode(silence, frameSize: _samplesPerFrame);
      final encryptResult = encryptor.encrypt(
        mediaType: dave.DAVEMediaType.DAVE_MEDIA_TYPE_AUDIO,
        ssrc: ssrc ?? 0,
        frame: opusFrame,
      );
      final davePayload = encryptResult.isSuccess ? encryptResult.frame : opusFrame;
      await sender.writeEncodedFrame(data: davePayload, durationMicros: BigInt.from(_frameDurationMicros));
      summary.audioFramesSent++;
    } catch (error) {
      log('failed to send silent audio frame: $error');
    }
  }

  void handleSpeaking({required Snowflake userId, required int ssrc}) {
    _userIdBySsrc[ssrc] = userId;
    _participant(userId);
  }

  /// Maps a remote participant's video/RTX SSRC(s) to their user id, from
  /// the voice gateway's Video opcode (12) - without this, an incoming video
  /// RTP packet's SSRC never resolves to a user (only [handleSpeaking],
  /// fed by the *audio* Speaking opcode, populated that map before), so
  /// [_waitForSsrcThenReceive] would wait forever and no remote video could
  /// ever be received, let alone decoded. Ignores the echo of this client's
  /// own [ProbeVoiceSession.startSyntheticVideo] call (`userId` is null for
  /// that, or equal to [selfUserId]).
  void handleVideoUpdate(VoiceVideoUpdate update) {
    if (update.userId == null) return;
    final userId = Snowflake.parse(update.userId!);
    if (userId == selfUserId) return;
    _userIdBySsrc[update.videoSsrc] = userId;
    for (final stream in update.streams) {
      _userIdBySsrc[stream.ssrc] = userId;
    }
    _participant(userId);
    log(
      'video (12) from $userId: videoSsrc=${update.videoSsrc} '
      'streams=${update.streams.map((s) => '${s.type}/${s.rid}/ssrc=${s.ssrc}/active=${s.active}').join(',')}',
    );
  }

  void _handlePeerConnectionEvent(PeerConnectionEvent event, Completer<void> gatherComplete) {
    switch (event) {
      case PeerConnectionEvent_IceGatheringStateChanged(:final field0):
        if (field0 == IceGatheringState.complete && !gatherComplete.isCompleted) {
          gatherComplete.complete();
        }
      case PeerConnectionEvent_ConnectionStateChanged(:final field0):
        log('connection state -> $field0');
        if (field0 == PeerConnectionState.connected) summary.webrtcConnected = true;
      case PeerConnectionEvent_IceConnectionStateChanged(:final field0):
        log('ICE connection state -> $field0');
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
    log('remote track arrived: kind=$kind');

    final packets = kind == MediaKind.video ? track.rawPackets() : track.packets();
    StreamSubscription<RemoteRtpPacket>? peekSub;
    peekSub = packets.listen((packet) {
      peekSub?.cancel();
      final userId = _userIdBySsrc[packet.ssrc];
      if (userId != null) {
        _startReceiving(userId, kind, packet, packets);
      } else {
        _pendingTracksBySsrc[packet.ssrc] = track;
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
      final previous = _videoProcessingChains[userId] ?? Future<void>.value();
      _videoProcessingChains[userId] = previous.then((_) => _decodeRemoteVideoPacket(userId, packet));
    } else {
      _handleRemoteAudioPacket(userId, packet);
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

  /// Accumulates depacketized (still-encrypted) chunks per user across one
  /// whole access unit, only decrypting once the RTP marker bit says the
  /// access unit is complete - mirroring the sender's whole-frame DAVE
  /// encryption (see `_encodeAndSendSyntheticVideoFrame`'s doc).
  Future<void> _decodeRemoteVideoPacket(Snowflake userId, RemoteRtpPacket packet) async {
    try {
      final depacketizer = await _videoDepacketizerFor(userId);
      final depacketized = await depacketizer.depacketize(data: packet.payload);
      if (depacketized.isNotEmpty) {
        (_videoFrameAccumulators[userId] ??= BytesBuilder(copy: false)).add(depacketized);
      }
      if (!packet.marker) return;

      final accumulator = _videoFrameAccumulators.remove(userId);
      final encryptedFrame = accumulator?.toBytes();
      if (encryptedFrame == null || encryptedFrame.isEmpty) return;

      final participant = _participant(userId);
      final decryptResult = participant.decryptor.decrypt(
        mediaType: dave.DAVEMediaType.DAVE_MEDIA_TYPE_VIDEO,
        encryptedFrame: encryptedFrame,
      );
      if (!decryptResult.isSuccess) {
        summary.videoDecryptFailures++;
        log('DAVE failed to decrypt a video frame from $userId (${encryptedFrame.length}B, code=${decryptResult.code})');
        return;
      }

      final decoder = await _videoDecoderFor(userId);
      final frame = await decoder.decode(data: decryptResult.frame);
      if (frame != null && !_disposed) {
        summary.videoFramesDecoded++;
        summary.receivedVideoFromUserIds.add(userId);
        if (summary.videoFramesDecoded <= 3 || summary.videoFramesDecoded % 150 == 0) {
          log('decoded remote video frame #${summary.videoFramesDecoded} from $userId (${frame.width}x${frame.height})');
        }
      }
    } catch (error, stackTrace) {
      _videoFrameAccumulators.remove(userId);
      log('failed to decode remote video packet from $userId: $error\n$stackTrace');
    }
  }

  void _handleRemoteAudioPacket(Snowflake userId, RemoteRtpPacket packet) {
    final participant = _participant(userId);
    try {
      final result = participant.decryptor.decrypt(
        mediaType: dave.DAVEMediaType.DAVE_MEDIA_TYPE_AUDIO,
        encryptedFrame: packet.payload,
      );
      final opusFrame = result.isSuccess ? result.frame : packet.payload;
      // Decode to prove the pipeline works, but discard the PCM - no
      // speaker (flutter_soloud) dependency in this probe.
      participant.opusDecoder.decode(opusFrame, frameSize: _samplesPerFrame);
      summary.audioPacketsReceived++;
    } catch (error) {
      log('failed to process incoming audio packet from $userId: $error');
    }
  }

  _RemoteParticipant _participant(Snowflake userId) =>
      _participantsByUserId.putIfAbsent(userId, () => _RemoteParticipant(sampleRate: _sampleRate, channels: _channels));

  int? _firstGroupMatch(RegExp pattern, String sdp) {
    for (final line in sdp.split(RegExp(r'\r\n|\n'))) {
      final match = pattern.firstMatch(line);
      if (match != null) return int.tryParse(match.group(1)!);
    }
    return null;
  }

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

  String _buildFragment(String sdp) {
    final lines = sdp.split(RegExp(r'\r\n|\n'));
    final vp8PayloadType = _firstGroupMatch(_vp8PayloadTypePattern, sdp);
    final vp8RtxPayloadType = _findRtxPayloadType(sdp, vp8PayloadType);

    bool isKeptRtpmap(String line) {
      final match = RegExp(r'^a=rtpmap:(\d+) ', caseSensitive: false).firstMatch(line);
      if (match == null) return false;
      final payloadType = int.tryParse(match.group(1)!);
      return payloadType != null &&
          (payloadType == _opusPayloadType || payloadType == vp8PayloadType || payloadType == vp8RtxPayloadType);
    }

    final kept = lines.where((line) => _fragmentAttributePattern.hasMatch(line) || isKeptRtpmap(line));
    return LinkedHashSet<String>.from(kept).join('\r\n');
  }

  String? _extractSdp(String? sessionDescriptionJson) {
    if (sessionDescriptionJson == null) return null;
    final match = RegExp(r'"sdp"\s*:\s*"((?:[^"\\]|\\.)*)"').firstMatch(sessionDescriptionJson);
    if (match == null) return null;
    return match.group(1)!.replaceAll(r'\n', '\n').replaceAll(r'\r', '\r').replaceAll(r'\"', '"').replaceAll(r'\\', '\\');
  }

  String _synthesizeAnswerSdp(String discordSdp) {
    final fingerprint = _firstLineMatch(discordSdp, RegExp(r'^a=fingerprint:(.+)$', multiLine: true));
    final iceUfrag = _firstLineMatch(discordSdp, RegExp(r'^a=ice-ufrag:(.+)$', multiLine: true));
    final icePwd = _firstLineMatch(discordSdp, RegExp(r'^a=ice-pwd:(.+)$', multiLine: true));
    final candidates =
        RegExp(r'^a=candidate:.+$', multiLine: true).allMatches(discordSdp).map((m) => m.group(0)!).toList();
    final connectionAddress = _firstLineMatch(discordSdp, RegExp(r'^c=IN IP4 (\S+)', multiLine: true)) ?? '0.0.0.0';

    if (fingerprint == null || iceUfrag == null || icePwd == null || candidates.isEmpty) {
      throw FormatException(
        'Discord answer sdp missing a required field (fingerprint=$fingerprint, iceUfrag=$iceUfrag, '
        'icePwd=$icePwd, candidates=${candidates.length})',
      );
    }

    String mediaSection({
      required String kind,
      required String mid,
      required List<int> payloadTypes,
      required List<String> rtpmapLines,
      required List<String> extraAttributes,
    }) {
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
    final videoPt = _videoPayloadType;

    final opusPt = _opusPayloadType;
    if (opusPt != null) {
      mids.add('0');
      sections.write(mediaSection(
        kind: 'audio',
        mid: '0',
        payloadTypes: [opusPt],
        rtpmapLines: ['a=rtpmap:$opusPt opus/48000/2'],
        extraAttributes: [
          'a=fmtp:$opusPt minptime=10;useinbandfec=1;usedtx=${videoPt != null ? 0 : 1}',
          'a=maxptime:60',
          'a=rtcp-fb:$opusPt transport-cc',
        ],
      ));
    }

    if (videoPt != null) {
      final mid = mids.length.toString();
      mids.add(mid);
      final rtxPt = _videoRtxPayloadType;
      final maxBitrateKbps = _videoBitrateBps ~/ 1000;
      sections.write(mediaSection(
        kind: 'video',
        mid: mid,
        payloadTypes: [videoPt, if (rtxPt != null) rtxPt],
        rtpmapLines: [
          'a=rtpmap:$videoPt H264/90000',
          if (rtxPt != null) 'a=rtpmap:$rtxPt rtx/90000',
        ],
        extraAttributes: [
          'a=fmtp:$videoPt level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f;x-google-max-bitrate=$maxBitrateKbps',
          if (rtxPt != null) 'a=fmtp:$rtxPt apt=$videoPt',
          'a=rtcp-fb:$videoPt ccm fir',
          'a=rtcp-fb:$videoPt nack',
          'a=rtcp-fb:$videoPt nack pli',
          'a=rtcp-fb:$videoPt goog-remb',
          'a=rtcp-fb:$videoPt transport-cc',
        ],
      ));
    }

    return 'v=0\r\n'
        'o=- 0 0 IN IP4 127.0.0.1\r\n'
        's=-\r\n'
        't=0 0\r\n'
        'a=group:BUNDLE ${mids.join(' ')}\r\n'
        '$sections';
  }

  String? _firstLineMatch(String sdp, RegExp pattern) => pattern.firstMatch(sdp)?.group(1)?.trim();

  String _wrapAsAnswerJson(String sdp) {
    final escaped = sdp.replaceAll('\\', r'\\').replaceAll('"', r'\"').replaceAll('\r\n', r'\r\n').replaceAll('\n', r'\n');
    return '{"type":"answer","sdp":"$escaped"}';
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _audioTimer?.cancel();
    _videoTimer?.cancel();
    _opusEncoder?.dispose();
    _videoEncoder?.dispose();
    _encryptor?.dispose();
    await _ratchetSub?.cancel();
    await _eventsSub?.cancel();
    for (final participant in _participantsByUserId.values) {
      participant.dispose();
    }
    _participantsByUserId.clear();
    _pendingTracksBySsrc.clear();
    _videoDecodersByUserId.clear();
    _videoDepacketizersByUserId.clear();
    _videoProcessingChains.clear();
    _videoFrameAccumulators.clear();
    await _peerConnection?.close();
  }
}

class _RemoteParticipant {
  _RemoteParticipant({required int sampleRate, required int channels})
    : opusDecoder = opus.OpusDecoder(sampleRate: sampleRate, channels: channels),
      decryptor = dave.DaveDecryptor()..transitionToPassthroughMode(true);

  final opus.OpusDecoder opusDecoder;
  final dave.DaveDecryptor decryptor;

  void dispose() {
    opusDecoder.dispose();
    decryptor.dispose();
  }
}
