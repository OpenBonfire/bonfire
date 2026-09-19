import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:opus/opus.dart';

void main() {
  test('encode/decode round-trip produces plausible PCM for a sine wave', () {
    const sampleRate = 48000;
    const channels = 1;
    const frameSize = 960; // 20ms at 48kHz

    final encoder = OpusEncoder(sampleRate: sampleRate, channels: channels);
    addTearDown(encoder.dispose);
    final decoder = OpusDecoder(sampleRate: sampleRate, channels: channels);
    addTearDown(decoder.dispose);

    // A 440Hz tone - encode() requires real (non-silent) audio input.
    final pcm = Int16List(frameSize);
    for (var i = 0; i < frameSize; i++) {
      pcm[i] = (sin(2 * pi * 440 * i / sampleRate) * 10000).round();
    }

    final packet = encoder.encode(pcm, frameSize: frameSize);
    expect(packet, isNotEmpty);
    expect(packet.length, lessThanOrEqualTo(maxOpusPacketBytes));

    final decoded = decoder.decode(packet, frameSize: frameSize);
    expect(decoded.length, frameSize * channels);

    // Lossy codec - not a bitwise match, but should be a recognizable tone
    // (RMS in the same ballpark as the input, not silence/garbage).
    final inputRms = sqrt(pcm.map((s) => s * s).reduce((a, b) => a + b) / pcm.length);
    final outputRms = sqrt(decoded.map((s) => s * s).reduce((a, b) => a + b) / decoded.length);
    expect(outputRms, greaterThan(inputRms * 0.5));
    expect(outputRms, lessThan(inputRms * 1.5));
  });

  test('decoder performs packet-loss concealment when data is null', () {
    final decoder = OpusDecoder(sampleRate: 48000, channels: 1);
    addTearDown(decoder.dispose);

    final concealed = decoder.decode(null, frameSize: 960);
    expect(concealed.length, 960);
  });
}
