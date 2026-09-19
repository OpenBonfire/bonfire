import 'dart:convert';
import 'dart:typed_data';

import 'package:bonfire/features/voice/services/voice_ip_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildIpDiscoveryRequest encodes type/length/ssrc correctly', () {
    final packet = buildIpDiscoveryRequest(0x1234);
    expect(packet.length, 74);

    final view = ByteData.sublistView(packet);
    expect(view.getUint16(0, Endian.big), 0x0001);
    expect(view.getUint16(2, Endian.big), 70);
    expect(view.getUint32(4, Endian.big), 0x1234);
  });

  test('parseIpDiscoveryResponse extracts address/port from a synthesized response', () {
    final packet = Uint8List(74);
    final view = ByteData.sublistView(packet);
    view.setUint16(0, 0x0002, Endian.big);
    view.setUint16(2, 70, Endian.big);
    view.setUint32(4, 0x1234, Endian.big);
    final address = utf8.encode('203.0.113.42');
    packet.setAll(8, address);
    view.setUint16(8 + 64, 54321, Endian.big);

    final result = parseIpDiscoveryResponse(packet);
    expect(result.address, '203.0.113.42');
    expect(result.port, 54321);
  });

  test('parseIpDiscoveryResponse rejects a non-response packet', () {
    final requestBytes = buildIpDiscoveryRequest(1);
    expect(() => parseIpDiscoveryResponse(requestBytes), throwsFormatException);
  });

  test('parseIpDiscoveryResponse rejects a too-short packet', () {
    expect(() => parseIpDiscoveryResponse(Uint8List(10)), throwsFormatException);
  });
}
