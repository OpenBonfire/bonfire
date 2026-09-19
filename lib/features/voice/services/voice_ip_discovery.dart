import 'dart:convert';
import 'dart:typed_data';

/// Builds and parses Discord's UDP IP Discovery packets - sent once over
/// the media UDP socket right after connecting, to learn this client's
/// externally-visible IP/port (through NAT) before sending Select Protocol.
///
/// See https://docs.discord.food/topics/voice-connections#ip-discovery.
const _requestType = 0x0001;
const _responseType = 0x0002;
const _payloadLength = 70; // SSRC (4) + address (64) + port (2)
const _addressFieldLength = 64;

/// Builds the IP Discovery request packet to send for [ssrc] (from Ready).
Uint8List buildIpDiscoveryRequest(int ssrc) {
  final packet = Uint8List(4 + _payloadLength);
  final view = ByteData.sublistView(packet);
  view.setUint16(0, _requestType, Endian.big);
  view.setUint16(2, _payloadLength, Endian.big);
  view.setUint32(4, ssrc, Endian.big);
  // Address (64 bytes) and port (2 bytes) are left zeroed in the request.
  return packet;
}

/// The client's externally-visible address, as reported by the voice
/// server's IP Discovery response.
class IpDiscoveryResult {
  const IpDiscoveryResult({required this.address, required this.port});
  final String address;
  final int port;
}

/// Parses an IP Discovery response packet. Throws [FormatException] if
/// [packet] doesn't look like one (callers should expect other packets -
/// e.g. early RTP - may arrive on the same socket and should just ignore
/// anything that doesn't parse as a discovery response).
IpDiscoveryResult parseIpDiscoveryResponse(Uint8List packet) {
  if (packet.length < 4 + _payloadLength) {
    throw FormatException('IP discovery response too short: ${packet.length} bytes');
  }
  final view = ByteData.sublistView(packet);
  final type = view.getUint16(0, Endian.big);
  if (type != _responseType) {
    throw FormatException('Not an IP discovery response (type=$type)');
  }

  final addressBytes = packet.sublist(8, 8 + _addressFieldLength);
  final nullIndex = addressBytes.indexOf(0);
  final address = utf8.decode(addressBytes.sublist(0, nullIndex == -1 ? addressBytes.length : nullIndex));
  final port = view.getUint16(8 + _addressFieldLength, Endian.big);

  return IpDiscoveryResult(address: address, port: port);
}
