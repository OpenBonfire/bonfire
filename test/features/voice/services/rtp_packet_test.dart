import 'dart:typed_data';

import 'package:bonfire/features/voice/services/rtp_packet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips a plain audio packet (no CSRC, no extension)', () {
    final packet = RtpPacket(
      header: const RtpHeader(
        payloadType: 120,
        marker: false,
        sequenceNumber: 4242,
        timestamp: 960 * 7,
        ssrc: 123456789,
      ),
      payload: Uint8List.fromList([1, 2, 3, 4, 5]),
    );

    final bytes = packet.toBytes();
    expect(bytes.length, 12 + 5);
    // Version 2, no padding/extension/CSRC -> 0x80.
    expect(bytes[0], 0x80);
    // No marker, PT 120 -> 0x78.
    expect(bytes[1], 0x78);

    final parsed = RtpPacket.parse(bytes);
    expect(parsed.header.payloadType, 120);
    expect(parsed.header.marker, isFalse);
    expect(parsed.header.sequenceNumber, 4242);
    expect(parsed.header.timestamp, 960 * 7);
    expect(parsed.header.ssrc, 123456789);
    expect(parsed.header.csrcs, isEmpty);
    expect(parsed.header.hasExtension, isFalse);
    expect(parsed.header.headerLength, 12);
    expect(parsed.payload, equals([1, 2, 3, 4, 5]));
  });

  test('parses CSRCs and the extension preamble, without touching encrypted extension contents', () {
    // A packet with 2 CSRCs and a header extension declaring 1 word (4
    // bytes) - per the transport-encryption AAD rule, those 4 bytes of
    // extension content are NOT parsed out separately; they stay part of
    // `payload` alongside the real (still-opaque) audio data.
    final bytes = Uint8List(12 + 8 + 4 + 4 + 3);
    final view = ByteData.sublistView(bytes);
    bytes[0] = 0x80 | 0x10 | 0x02; // version 2, extension bit, 2 CSRCs
    bytes[1] = 0x80 | 101; // marker + payload type 101
    view.setUint16(2, 1, Endian.big);
    view.setUint32(4, 90000, Endian.big);
    view.setUint32(8, 42, Endian.big);
    view.setUint32(12, 111, Endian.big);
    view.setUint32(16, 222, Endian.big);
    view.setUint16(20, 0xBEDE, Endian.big);
    view.setUint16(22, 1, Endian.big); // 1 word = 4 bytes of extension
    bytes.setAll(24, [0x11, 0x22, 0x33, 0x44, 9, 9, 9]); // extension bytes + payload

    final parsed = RtpPacket.parse(bytes);
    expect(parsed.header.marker, isTrue);
    expect(parsed.header.csrcs, [111, 222]);
    expect(parsed.header.hasExtension, isTrue);
    expect(parsed.header.extensionProfile, 0xBEDE);
    expect(parsed.header.extensionWordCount, 1);
    expect(parsed.header.headerLength, 12 + 8 + 4);
    // Everything after the AAD boundary, extension content included.
    expect(parsed.payload, equals([0x11, 0x22, 0x33, 0x44, 9, 9, 9]));
  });

  test('RtpHeader.toBytes() only covers the AAD portion, not the payload', () {
    const header = RtpHeader(payloadType: 120, marker: false, sequenceNumber: 1, timestamp: 1, ssrc: 1);
    expect(header.toBytes().length, 12);
    expect(header.headerLength, 12);
  });

  test('parse() rejects a non-version-2 packet', () {
    final bytes = Uint8List.fromList([0x00, 0x78, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(() => RtpPacket.parse(bytes), throwsFormatException);
  });

  test('parse() rejects a too-short packet', () {
    expect(() => RtpPacket.parse(Uint8List(4)), throwsFormatException);
  });
}
