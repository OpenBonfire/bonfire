import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dave/dave.dart' as dave;
import 'package:firebridge/firebridge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:opus/opus.dart' as opus;
import 'package:record/record.dart';

import 'dave_voice_session.dart';
import 'rtp_packet.dart';
import 'voice_gateway.dart';
import 'voice_ip_discovery.dart';
import 'voice_transport_crypto.dart';

const _sampleRate = 48000;
const _channels = 1;
const _samplesPerFrame = 960; // 20ms at 48kHz
const _bytesPerFrame = _samplesPerFrame * _channels * 2; // 16-bit PCM
const _audioPayloadType = 120; // Opus, matching Select Protocol's codec entry

/// Thrown when microphone permission isn't granted.
class VoiceMicrophonePermissionDeniedException implements Exception {
  const VoiceMicrophonePermissionDeniedException();
  @override
  String toString() => 'Microphone permission was denied - cannot join voice.';
}

/// Owns the actual UDP media transport for a voice call: IP discovery, the
/// RTP send/receive loops, transport encryption, Opus encode/decode, mic
/// capture and speaker playback, and (when [daveSession] is provided) DAVE
/// frame encryption/decryption.
///
/// This is the real-time media path - see `VoiceGateway` for the signalling
/// this is paired with, and `DaveVoiceSession` for the MLS/E2EE state
/// machine driving [daveSession].
///
/// Known simplification for this first pass: incoming packets are decoded
/// and played as they arrive, with no jitter buffer beyond what SoLoud
/// itself buffers internally - fine on a good connection, but real-world
/// packet loss/reordering will sound rougher than it should until a proper
/// jitter buffer is added.
class VoiceMediaSession {
  VoiceMediaSession({
    required this.gateway,
    required this.selfUserId,
    this.daveSession,
  });

  final VoiceGateway gateway;
  final Snowflake selfUserId;

  /// When non-null, outgoing/incoming frames are DAVE-encrypted/decrypted
  /// using ratchets this emits. When null, media is sent/received as plain
  /// Opus (transport encryption still applies either way).
  final DaveVoiceSession? daveSession;

  RawDatagramSocket? _socket;
  InternetAddress? _remoteAddress;
  int? _remotePort;
  int? _ssrc;
  VoiceTransportCrypto? _transportCrypto;

  StreamSubscription<DaveRatchetUpdate>? _ratchetSub;
  dave.DaveEncryptor? _encryptor;
  final Map<Snowflake, _RemoteParticipant> _participantsByUserId = {};
  final Map<int, Snowflake> _userIdBySsrc = {};

  opus.OpusEncoder? _opusEncoder;
  AudioRecorder? _recorder;
  StreamSubscription<Uint8List>? _micSubscription;
  final BytesBuilder _micBuffer = BytesBuilder(copy: false);

  int _sequenceNumber = 0;
  int _timestamp = 0;
  bool _disposed = false;

  /// Opens the UDP socket to the voice server and performs IP Discovery,
  /// returning our externally-visible address/port to use in Select
  /// Protocol. Must be called before [start].
  Future<IpDiscoveryResult> connectAndDiscoverIp(VoiceReady ready) async {
    _ssrc = ready.ssrc;
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _socket = socket;
    _remoteAddress = InternetAddress(ready.ip);
    _remotePort = ready.port;

    final discoveryCompleter = Completer<IpDiscoveryResult>();
    socket.listen((event) => _handleSocketEvent(event, discoveryCompleter));

    socket.send(buildIpDiscoveryRequest(ready.ssrc), _remoteAddress!, _remotePort!);
    debugPrint('VoiceMediaSession: sent IP discovery request to ${ready.ip}:${ready.port}');

    return discoveryCompleter.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('IP discovery did not receive a response'),
    );
  }

  /// Starts capturing/sending mic audio and is ready to decode/play
  /// incoming audio. Call after Session Description has been received and
  /// [connectAndDiscoverIp] has completed.
  Future<void> start({required String mode, required Uint8List secretKey}) async {
    _transportCrypto = VoiceTransportCrypto(mode: mode, secretKey: secretKey);

    // Must happen before anything below that can construct a
    // _RemoteParticipant (which needs a live SoLoud instance to open its
    // buffer stream) - including the ratchet catch-up further down, which
    // can do exactly that as soon as it runs.
    //
    // Only init() if not already initialized: main.dart already calls
    // SoLoud.instance.init() once at app boot, and per that method's own
    // doc, calling it again while already initialized doesn't no-op - it
    // *deinitializes and reinitializes the whole engine*, destroying every
    // existing sound. Calling it unconditionally here meant it was tearing
    // down and rebuilding the shared engine on every voice call, racing
    // with (and permanently invalidating) the very _RemoteParticipant
    // buffer stream being created concurrently as RTP packets started
    // arriving - the actual cause of the persistent
    // PlayerErrors.soundHashNotFound seen in live testing.
    if (!SoLoud.instance.isInitialized) {
      await SoLoud.instance.init();
    }

    // Starts (and stays, until a self DaveRatchetUpdate arrives - see
    // _handleRatchetUpdate) in passthrough mode, which makes encrypt()
    // itself just pass frames through unchanged. Created unconditionally
    // (whether or not DAVE ends up active for this call) so _sendFrame
    // doesn't need to branch on it.
    final encryptor = dave.DaveEncryptor()..passthroughMode = true;
    // Required: without this, libdave's frame processor sees Codec::Unknown
    // for this SSRC, hits its "unsupported codec" branch, and silently
    // fails to encrypt (an assert() that's compiled out in release builds -
    // no crash, no error, encrypt() just falls back to passthrough-shaped
    // failure). _sendFrame's isSuccess fallback would then keep sending
    // plain Opus even once passthroughMode is false, while a receiver whose
    // ratchet *did* arrive correctly tries to DAVE-decrypt already-plain
    // Opus - producing garbage the Opus decoder rejects.
    final ssrc = _ssrc;
    if (ssrc != null) {
      encryptor.assignSsrcToCodec(ssrc, dave.DAVECodec.DAVE_CODEC_OPUS);
    } else {
      debugPrint(
        'VoiceMediaSession: start() called with no ssrc set - '
        'connectAndDiscoverIp() should always run first. DAVE encryption '
        'will silently no-op for this session.',
      );
    }
    _encryptor = encryptor;

    // Subscribe *before* reading the catch-up snapshot below, so nothing
    // that fires in between is missed.
    _ratchetSub = daveSession?.onRatchetUpdate.listen(_handleRatchetUpdate);
    // DaveVoiceSession's handshake only depends on the gateway connection,
    // so it can (and in live testing, does) finish deriving ratchets
    // before this method - which waits on IP discovery, mic permission,
    // and the SoLoud init above - gets this far. onRatchetUpdate is a
    // plain broadcast stream with no replay, so catch up on anything
    // already derived (applying an update we already saw via the live
    // subscription above is harmless - it's idempotent).
    final known = daveSession?.knownRatchets;
    if (known != null) {
      for (final entry in known.entries) {
        _handleRatchetUpdate(
          DaveRatchetUpdate(userId: entry.key, ratchet: entry.value, isSelf: entry.key == selfUserId),
        );
      }
    }

    final recorder = AudioRecorder();
    _recorder = recorder;
    if (!await recorder.hasPermission()) {
      throw const VoiceMicrophonePermissionDeniedException();
    }

    _opusEncoder = opus.OpusEncoder(sampleRate: _sampleRate, channels: _channels);

    final micStream = await recorder.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: _channels,
    ));
    _micSubscription = micStream.listen(_handleMicData);

    debugPrint('VoiceMediaSession: started (ssrc=$_ssrc, mode=$mode, dave=${daveSession != null})');
  }

  void _handleRatchetUpdate(DaveRatchetUpdate update) {
    if (update.isSelf) {
      // _encryptor is created in start(), before this subscription exists.
      _encryptor!.setKeyRatchet(update.ratchet);
      _encryptor!.passthroughMode = false;
      debugPrint(
        '[VoiceDave] self key ratchet updated, DAVE encryption active '
        '(hasKeyRatchet=${_encryptor!.hasKeyRatchet}, passthroughMode=${_encryptor!.passthroughMode})',
      );
    } else {
      _participant(update.userId).decryptor.transitionToKeyRatchet(update.ratchet);
      _participant(update.userId).decryptor.transitionToPassthroughMode(false);
      _participant(update.userId)._hasRatchet = true;
      debugPrint('[VoiceDave] key ratchet updated for ${update.userId}');
    }
  }

  // --- Sending ---

  void _handleMicData(Uint8List chunk) {
    _micBuffer.add(chunk);
    final buffered = _micBuffer.toBytes();
    var offset = 0;
    while (buffered.length - offset >= _bytesPerFrame) {
      final frame = Uint8List.sublistView(buffered, offset, offset + _bytesPerFrame);
      _sendFrame(Int16List.sublistView(frame));
      offset += _bytesPerFrame;
    }
    _micBuffer.clear();
    if (offset < buffered.length) {
      _micBuffer.add(buffered.sublist(offset));
    }
  }

  Future<void> _sendFrame(Int16List pcm) async {
    final socket = _socket;
    final transportCrypto = _transportCrypto;
    final encoder = _opusEncoder;
    final encryptor = _encryptor;
    final ssrc = _ssrc;
    if (socket == null || transportCrypto == null || encoder == null || encryptor == null || ssrc == null) {
      return;
    }

    try {
      final opusFrame = encoder.encode(pcm, frameSize: _samplesPerFrame);

      // encryptor starts (and stays, until DAVE is negotiated) in
      // passthrough mode, which makes encrypt() pass the frame through
      // unchanged - safe to call unconditionally.
      final encryptResult = encryptor.encrypt(
        mediaType: dave.DAVEMediaType.DAVE_MEDIA_TYPE_AUDIO,
        ssrc: ssrc,
        frame: opusFrame,
      );
      final davePayload = encryptResult.isSuccess ? encryptResult.frame : opusFrame;

      if (_sequenceNumber < 5 || _sequenceNumber % 250 == 0) {
        debugPrint(
          '[VoiceSend] seq=$_sequenceNumber opus=${opusFrame.length}B '
          'encryptCode=${encryptResult.code} daveFrame=${davePayload.length}B '
          'passthrough=${encryptor.passthroughMode} hasKeyRatchet=${encryptor.hasKeyRatchet}',
        );
      }

      final header = RtpHeader(
        payloadType: _audioPayloadType,
        marker: false,
        sequenceNumber: _sequenceNumber,
        timestamp: _timestamp,
        ssrc: ssrc,
      );
      _sequenceNumber = (_sequenceNumber + 1) & 0xFFFF;
      _timestamp = (_timestamp + _samplesPerFrame) & 0xFFFFFFFF;

      final encrypted = await transportCrypto.encrypt(header: header.toBytes(), plaintext: davePayload);
      final packet = RtpPacket(header: header, payload: encrypted);
      socket.send(packet.toBytes(), _remoteAddress!, _remotePort!);
    } catch (error, stackTrace) {
      debugPrint('VoiceMediaSession: failed to send audio frame: $error\n$stackTrace');
    }
  }

  // --- Receiving ---

  void _handleSocketEvent(RawSocketEvent event, Completer<IpDiscoveryResult> discoveryCompleter) {
    if (event != RawSocketEvent.read) return;
    final datagram = _socket?.receive();
    if (datagram == null) return;

    final data = datagram.data;
    if (data.isEmpty) return;

    // IP discovery responses start with 0x00 0x02; RTP packets always start
    // with 0x80 (RTP version 2, no padding/extension/CSRC on anything we
    // send, and Discord's own packets follow the same convention).
    if (data[0] == 0x00 && !discoveryCompleter.isCompleted) {
      try {
        discoveryCompleter.complete(parseIpDiscoveryResponse(data));
        return;
      } catch (error) {
        debugPrint('VoiceMediaSession: failed to parse IP discovery response: $error');
        return;
      }
    }

    _handleRtpPacket(data);
  }

  Future<void> _handleRtpPacket(Uint8List data) async {
    final transportCrypto = _transportCrypto;
    if (transportCrypto == null) return;

    final RtpPacket packet;
    try {
      packet = RtpPacket.parse(data);
    } catch (error) {
      debugPrint('VoiceMediaSession: failed to parse incoming RTP packet: $error');
      return;
    }
    if (packet.header.payloadType != _audioPayloadType) return;

    final userId = _userIdBySsrc[packet.header.ssrc];
    if (userId == null) {
      // Haven't seen a Speaking update mapping this SSRC yet - drop until
      // we do (should arrive very quickly after someone starts talking).
      return;
    }

    final participant = _participant(userId);
    // Diagnostic-only counter, starting at 0 - the packet's own RTP
    // sequence number starts at an arbitrary value the remote sender
    // chose, so gating logging on it (as before) meant the "log the first
    // few packets" condition effectively never fired for real traffic.
    final localSeq = participant._receivedCount++;

    Uint8List? decryptedPayload;
    dave.DaveDecryptResult? result;
    Uint8List? opusFrame;
    try {
      decryptedPayload = await transportCrypto.decrypt(
        header: RtpHeader(
          payloadType: packet.header.payloadType,
          marker: packet.header.marker,
          sequenceNumber: packet.header.sequenceNumber,
          timestamp: packet.header.timestamp,
          ssrc: packet.header.ssrc,
          csrcs: packet.header.csrcs,
          hasExtension: packet.header.hasExtension,
          extensionProfile: packet.header.extensionProfile,
          extensionWordCount: packet.header.extensionWordCount,
        ).toBytes(),
        payload: packet.payload,
      );

      // Per RtpPacket.payload's doc: once transport-decrypted, the
      // plaintext starts with `extensionWordCount * 4` bytes of RTP header
      // extension content (Discord/WebRTC senders commonly attach a
      // one-byte audio-level extension on every audio packet) before the
      // actual DAVE-encrypted-or-passthrough audio frame. That prefix must
      // be stripped here, or it corrupts every frame fed to DAVE/Opus.
      final extensionBytes = packet.header.extensionWordCount * 4;
      if (extensionBytes > decryptedPayload.length) {
        throw FormatException(
          'decrypted payload (${decryptedPayload.length}B) shorter than declared '
          'extension length (${extensionBytes}B)',
        );
      }
      final davePayload = extensionBytes == 0
          ? decryptedPayload
          : Uint8List.sublistView(decryptedPayload, extensionBytes);

      // The decryptor starts (and stays, until a DaveRatchetUpdate arrives -
      // see _handleRatchetUpdate) in passthrough mode, which makes
      // decrypt() itself just pass the frame through unchanged. So this is
      // safe to call unconditionally, whether or not DAVE is active at all.
      result = participant.decryptor.decrypt(
        mediaType: dave.DAVEMediaType.DAVE_MEDIA_TYPE_AUDIO,
        encryptedFrame: davePayload,
      );
      opusFrame = result.isSuccess ? result.frame : davePayload;

      if (localSeq < 5 || localSeq % 250 == 0) {
        debugPrint(
          '[VoiceRecv] #$localSeq rtpSeq=${packet.header.sequenceNumber} ssrc=${packet.header.ssrc} '
          'wire=${packet.payload.length}B transportDecrypted=${decryptedPayload.length}B '
          'extensionBytes=$extensionBytes decryptCode=${result.code} chosenFrame=${opusFrame.length}B '
          'hasRatchet=${participant._hasRatchet} first8=${_hexDump(opusFrame)}',
        );
      }

      final pcm = participant.opusDecoder.decode(opusFrame, frameSize: _samplesPerFrame);
      SoLoud.instance.addAudioDataStream(participant.audioSource, pcm.buffer.asUint8List());
    } catch (error) {
      debugPrint(
        'VoiceMediaSession: failed to process incoming packet from $userId '
        '(#$localSeq rtpSeq=${packet.header.sequenceNumber}, wire=${packet.payload.length}B, '
        'transportDecrypted=${decryptedPayload?.length}B, decryptCode=${result?.code}, '
        'chosenFrame=${opusFrame?.length}B'
        '${opusFrame != null ? ', first8=${_hexDump(opusFrame)}' : ''}): $error',
      );
    }
  }

  String _hexDump(Uint8List bytes) =>
      bytes.take(8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

  /// Called by the voice connection controller when a Speaking event
  /// arrives, to learn which user a given SSRC belongs to (needed to route
  /// incoming RTP packets and pick the right DAVE key ratchet).
  void handleSpeaking({required Snowflake userId, required int ssrc}) {
    _userIdBySsrc[ssrc] = userId;
    _participant(userId); // ensure playback state exists once they're known
  }

  _RemoteParticipant _participant(Snowflake userId) => _participantsByUserId.putIfAbsent(
    userId,
    () => _RemoteParticipant(sampleRate: _sampleRate, channels: _channels),
  );

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    await _micSubscription?.cancel();
    await _recorder?.dispose();
    _opusEncoder?.dispose();
    _encryptor?.dispose();
    await _ratchetSub?.cancel();

    for (final participant in _participantsByUserId.values) {
      participant.dispose();
    }
    _participantsByUserId.clear();

    _socket?.close();
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

  /// Diagnostic only - tracks whether a real DAVE key ratchet has ever been
  /// applied to [decryptor] (there's no getter for this on the C API
  /// itself, since passthrough-vs-real-decrypt is meant to be transparent
  /// to callers).
  bool _hasRatchet = false;

  /// Diagnostic only - counts packets received *locally* from this
  /// participant, starting at 0. Unlike the packet's own RTP sequence
  /// number (which starts at an arbitrary value chosen by the remote
  /// sender), this is safe to gate logging on for "first few packets".
  int _receivedCount = 0;

  void dispose() {
    opusDecoder.dispose();
    decryptor.dispose();
    SoLoud.instance.disposeSource(audioSource);
  }
}
