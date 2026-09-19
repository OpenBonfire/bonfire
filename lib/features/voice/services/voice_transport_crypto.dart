import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// The transport encryption modes this client supports, in preference
/// order (most-preferred first). Discord requires every client to support
/// `aead_xchacha20_poly1305_rtpsize`, and prefers `aead_aes256_gcm_rtpsize`
/// when available.
///
/// See https://docs.discord.food/topics/voice-connections#transport-encryption-mode.
const supportedTransportEncryptionModes = [
  'aead_aes256_gcm_rtpsize',
  'aead_xchacha20_poly1305_rtpsize',
];

/// Picks the best mode this client supports out of the modes the voice
/// server reported in Ready, or null if none match (shouldn't happen in
/// practice, since `aead_xchacha20_poly1305_rtpsize` is mandatory).
String? pickTransportEncryptionMode(List<String> serverModes) {
  for (final mode in supportedTransportEncryptionModes) {
    if (serverModes.contains(mode)) return mode;
  }
  return null;
}

/// Encrypts/decrypts RTP (and RTCP) packet payloads using one of Discord's
/// `*_rtpsize` AEAD transport encryption modes - this is the client<->SFU
/// transport layer, separate from (and outside of) DAVE's end-to-end
/// encryption of the media frame contents.
///
/// Wire format for both supported modes (verified against multiple
/// independent open-source Discord voice client implementations -
/// discord.js's `@discordjs/voice`, discord.py, and songbird - since
/// Discord's own docs only specify the nonce type, not its exact
/// construction):
/// `[RTP header, cleartext, used as AAD] + [AEAD ciphertext] + [16-byte auth tag] + [4-byte nonce counter, cleartext, big-endian]`
///
/// The 4-byte counter is the low bytes of the cipher's full nonce (12 bytes
/// for AES-256-GCM, 24 for XChaCha20-Poly1305) - the rest of the nonce
/// buffer is zero. The counter increments by 1 per packet sent and wraps
/// at 2^32-1; each direction (send/receive) tracks it independently, since
/// the value comes directly off the wire when decrypting.
class VoiceTransportCrypto {
  VoiceTransportCrypto({required String mode, required Uint8List secretKey})
    : _cipher = _cipherFor(mode),
      _nonceLength = mode == 'aead_aes256_gcm_rtpsize' ? 12 : 24,
      _secretKey = SecretKey(secretKey);

  final Cipher _cipher;
  final int _nonceLength;
  final SecretKey _secretKey;

  int _sendNonceCounter = 0;

  static Cipher _cipherFor(String mode) => switch (mode) {
    'aead_aes256_gcm_rtpsize' => AesGcm.with256bits(),
    'aead_xchacha20_poly1305_rtpsize' => Xchacha20.poly1305Aead(),
    _ => throw ArgumentError.value(mode, 'mode', 'Unsupported transport encryption mode'),
  };

  /// Encrypts [plaintext] (the RTP payload - e.g. a DAVE-encrypted Opus
  /// frame) for sending, authenticating [header] (the RTP header bytes) as
  /// AAD. Returns `ciphertext + 16-byte tag + 4-byte nonce suffix`, ready
  /// to append directly after [header] to form the full UDP packet.
  Future<Uint8List> encrypt({required Uint8List header, required Uint8List plaintext}) async {
    final nonce = _buildNonce(_sendNonceCounter);
    _sendNonceCounter = (_sendNonceCounter + 1) & 0xFFFFFFFF;

    final secretBox = await _cipher.encrypt(plaintext, secretKey: _secretKey, nonce: nonce, aad: header);

    final counterSuffix = nonce.sublist(0, 4);
    final result = Uint8List(secretBox.cipherText.length + secretBox.mac.bytes.length + 4);
    result.setAll(0, secretBox.cipherText);
    result.setAll(secretBox.cipherText.length, secretBox.mac.bytes);
    result.setAll(secretBox.cipherText.length + secretBox.mac.bytes.length, counterSuffix);
    return result;
  }

  /// Decrypts an RTP payload received on the wire (the trailing 4-byte
  /// nonce suffix included), authenticating [header] as AAD. Throws if
  /// authentication fails (a corrupted, tampered, or misaligned packet).
  Future<Uint8List> decrypt({required Uint8List header, required Uint8List payload}) async {
    const macLength = 16;
    const nonceSuffixLength = 4;
    if (payload.length < macLength + nonceSuffixLength) {
      throw const FormatException('Encrypted RTP payload too short to contain a tag and nonce suffix');
    }

    final cipherTextEnd = payload.length - macLength - nonceSuffixLength;
    final cipherText = Uint8List.sublistView(payload, 0, cipherTextEnd);
    final mac = Mac(payload.sublist(cipherTextEnd, cipherTextEnd + macLength));
    final counter = ByteData.sublistView(payload, payload.length - 4).getUint32(0, Endian.big);
    final nonce = _buildNonce(counter);

    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
    final plaintext = await _cipher.decrypt(secretBox, secretKey: _secretKey, aad: header);
    return Uint8List.fromList(plaintext);
  }

  Uint8List _buildNonce(int counter) {
    final nonce = Uint8List(_nonceLength);
    ByteData.sublistView(nonce).setUint32(0, counter, Endian.big);
    return nonce;
  }
}
