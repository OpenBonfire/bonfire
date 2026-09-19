import 'dart:typed_data';

/// An RTP packet (RFC 3550) header, scoped to what's needed to send/receive
/// Discord voice UDP audio: no padding, no CSRCs (never sent by us, though
/// tolerated when parsing another sender's packet), and the one-byte
/// extension profile (0xBEDE) Discord sometimes uses.
///
/// Important: when transport encryption is active (see
/// `VoiceTransportCrypto`), only the fixed header + CSRCs + the 4-byte
/// extension preamble are authenticated cleartext (AAD) - "the individual
/// RTP extension elements are encrypted with the RTP payload"
/// (docs.discord.food). So [headerLength] is exactly the AAD boundary:
/// everything from there to the end of the datagram (extension contents
/// included, if any) is the AEAD-protected region, and this class
/// deliberately does NOT attempt to parse extension *contents* out of a
/// still-encrypted wire packet - that's meaningless before decryption, and
/// this app doesn't need per-packet extension data for plain audio anyway
/// (the Speaking opcode covers voice-activity state instead).
class RtpHeader {
  const RtpHeader({
    required this.payloadType,
    required this.marker,
    required this.sequenceNumber,
    required this.timestamp,
    required this.ssrc,
    this.csrcs = const [],
    this.hasExtension = false,
    this.extensionProfile,
    this.extensionWordCount = 0,
  });

  /// RTP payload type (e.g. 120 for Discord's default Opus configuration).
  final int payloadType;

  /// Set on the final packet of an encoded video frame; unused for audio.
  final bool marker;

  final int sequenceNumber;
  final int timestamp;
  final int ssrc;
  final List<int> csrcs;

  /// Whether this packet carries a header extension. When true, the
  /// AAD/header includes the 4-byte extension preamble, but not its
  /// contents - see the class doc.
  final bool hasExtension;

  /// The RTP extension profile (0xBEDE for Discord's one-byte extensions),
  /// used only when [hasExtension] is true.
  final int? extensionProfile;

  /// The number of 32-bit words the extension occupies (from the
  /// unencrypted length field in its preamble) - callers need this to know
  /// how many of the AEAD-decrypted plaintext's leading bytes are extension
  /// content vs. the actual audio payload. 0 when [hasExtension] is false.
  final int extensionWordCount;

  /// The length, in bytes, of the AAD/header region: fixed header (12) +
  /// CSRCs + the 4-byte extension preamble if present. Everything from
  /// here to the end of a wire packet is the AEAD-protected region.
  int get headerLength => 12 + csrcs.length * 4 + (hasExtension ? 4 : 0);

  /// Builds the header bytes (the AAD).
  Uint8List toBytes() {
    final header = Uint8List(headerLength);
    final view = ByteData.sublistView(header);

    header[0] = 0x80 | (hasExtension ? 0x10 : 0) | (csrcs.length & 0x0F);
    header[1] = (marker ? 0x80 : 0) | (payloadType & 0x7F);
    view.setUint16(2, sequenceNumber, Endian.big);
    view.setUint32(4, timestamp, Endian.big);
    view.setUint32(8, ssrc, Endian.big);

    var offset = 12;
    for (final csrc in csrcs) {
      view.setUint32(offset, csrc, Endian.big);
      offset += 4;
    }

    if (hasExtension) {
      view.setUint16(offset, extensionProfile ?? 0xBEDE, Endian.big);
      view.setUint16(offset + 2, extensionWordCount, Endian.big);
    }

    return header;
  }

  /// Parses the header (AAD) portion of a raw wire packet.
  factory RtpHeader.parse(Uint8List data) {
    if (data.length < 12) {
      throw FormatException('RTP packet too short: ${data.length} bytes');
    }
    final view = ByteData.sublistView(data);

    final versionAndFlags = data[0];
    final version = versionAndFlags >> 6;
    if (version != 2) {
      throw FormatException('Unsupported RTP version: $version');
    }
    final hasExtensionBit = (versionAndFlags & 0x10) != 0;
    final csrcCount = versionAndFlags & 0x0F;

    final payloadTypeByte = data[1];
    final marker = (payloadTypeByte & 0x80) != 0;
    final payloadType = payloadTypeByte & 0x7F;

    final sequenceNumber = view.getUint16(2, Endian.big);
    final timestamp = view.getUint32(4, Endian.big);
    final ssrc = view.getUint32(8, Endian.big);

    var offset = 12;
    final csrcs = <int>[];
    for (var i = 0; i < csrcCount; i++) {
      if (offset + 4 > data.length) {
        throw const FormatException('RTP packet truncated in CSRC list');
      }
      csrcs.add(view.getUint32(offset, Endian.big));
      offset += 4;
    }

    int? extensionProfile;
    var extensionWordCount = 0;
    if (hasExtensionBit) {
      if (offset + 4 > data.length) {
        throw const FormatException('RTP packet truncated in extension preamble');
      }
      extensionProfile = view.getUint16(offset, Endian.big);
      extensionWordCount = view.getUint16(offset + 2, Endian.big);
    }

    return RtpHeader(
      payloadType: payloadType,
      marker: marker,
      sequenceNumber: sequenceNumber,
      timestamp: timestamp,
      ssrc: ssrc,
      csrcs: csrcs,
      hasExtension: hasExtensionBit,
      extensionProfile: extensionProfile,
      extensionWordCount: extensionWordCount,
    );
  }
}

/// A full raw wire RTP packet split into its AAD (header) and the region
/// after it (application payload for a plaintext packet; ciphertext + tag +
/// nonce suffix for a transport-encrypted one - see `VoiceTransportCrypto`).
class RtpPacket {
  const RtpPacket({required this.header, required this.payload});

  final RtpHeader header;

  /// Everything after the header. For received wire packets this is still
  /// transport-encrypted (and, once decrypted, starts with
  /// `header.extensionWordCount * 4` bytes of extension content if
  /// [RtpHeader.hasExtension] is true). For packets this app builds to
  /// send, this is the plaintext payload to hand to
  /// `VoiceTransportCrypto.encrypt`.
  final Uint8List payload;

  Uint8List toBytes() {
    final headerBytes = header.toBytes();
    final bytes = Uint8List(headerBytes.length + payload.length);
    bytes.setAll(0, headerBytes);
    bytes.setAll(headerBytes.length, payload);
    return bytes;
  }

  factory RtpPacket.parse(Uint8List data) {
    final header = RtpHeader.parse(data);
    return RtpPacket(header: header, payload: Uint8List.sublistView(data, header.headerLength));
  }
}
