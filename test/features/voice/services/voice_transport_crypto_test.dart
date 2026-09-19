import 'dart:typed_data';

import 'package:bonfire/features/voice/services/voice_transport_crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pickTransportEncryptionMode', () {
    test('prefers aead_aes256_gcm_rtpsize when both are offered', () {
      expect(
        pickTransportEncryptionMode(['aead_xchacha20_poly1305_rtpsize', 'aead_aes256_gcm_rtpsize']),
        'aead_aes256_gcm_rtpsize',
      );
    });

    test('falls back to aead_xchacha20_poly1305_rtpsize when gcm is unavailable', () {
      expect(
        pickTransportEncryptionMode(['aead_xchacha20_poly1305_rtpsize', 'xsalsa20_poly1305']),
        'aead_xchacha20_poly1305_rtpsize',
      );
    });

    test('returns null when nothing supported is offered', () {
      expect(pickTransportEncryptionMode(['xsalsa20_poly1305']), isNull);
    });
  });

  for (final mode in supportedTransportEncryptionModes) {
    group(mode, () {
      late Uint8List secretKey;

      setUp(() {
        secretKey = Uint8List.fromList(List.generate(32, (i) => i));
      });

      test('encrypt/decrypt round-trips, with independent send/receive counters', () async {
        final sender = VoiceTransportCrypto(mode: mode, secretKey: secretKey);
        final receiver = VoiceTransportCrypto(mode: mode, secretKey: secretKey);

        final header = Uint8List.fromList([0x80, 0x78, 0, 1, 0, 0, 0, 1, 0, 0, 0, 42]);
        final plaintext = Uint8List.fromList(List.generate(40, (i) => i * 3 % 256));

        for (var i = 0; i < 3; i++) {
          final encrypted = await sender.encrypt(header: header, plaintext: plaintext);
          // ciphertext (same length as plaintext for GCM/Poly1305) + 16-byte
          // tag + 4-byte nonce suffix.
          expect(encrypted.length, plaintext.length + 16 + 4);

          final decrypted = await receiver.decrypt(header: header, payload: encrypted);
          expect(decrypted, equals(plaintext));
        }
      });

      test('a tampered ciphertext fails authentication', () async {
        final sender = VoiceTransportCrypto(mode: mode, secretKey: secretKey);
        final receiver = VoiceTransportCrypto(mode: mode, secretKey: secretKey);
        final header = Uint8List.fromList([0x80, 0x78, 0, 1, 0, 0, 0, 1, 0, 0, 0, 42]);

        final encrypted = await sender.encrypt(header: header, plaintext: Uint8List.fromList([1, 2, 3]));
        encrypted[0] ^= 0xFF;

        expect(() => receiver.decrypt(header: header, payload: encrypted), throwsA(anything));
      });

      test('a mismatched AAD (RTP header) fails authentication', () async {
        final sender = VoiceTransportCrypto(mode: mode, secretKey: secretKey);
        final receiver = VoiceTransportCrypto(mode: mode, secretKey: secretKey);

        final encrypted = await sender.encrypt(
          header: Uint8List.fromList([0x80, 0x78, 0, 1, 0, 0, 0, 1, 0, 0, 0, 42]),
          plaintext: Uint8List.fromList([1, 2, 3]),
        );

        final wrongHeader = Uint8List.fromList([0x80, 0x78, 0, 2, 0, 0, 0, 1, 0, 0, 0, 42]);
        expect(() => receiver.decrypt(header: wrongHeader, payload: encrypted), throwsA(anything));
      });
    });
  }
}
