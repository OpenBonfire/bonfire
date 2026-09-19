import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:dave/dave.dart';

void main() {
  test('libdave loads and reports a protocol version', () {
    expect(daveMaxSupportedProtocolVersion(), greaterThan(0));
  });

  test('a session can initialize and generate a marshalled key package', () {
    final failures = <String>[];
    final session = DaveSession(
      onMlsFailure: (source, reason) => failures.add('$source: $reason'),
    );
    addTearDown(session.dispose);

    // libdave parses user IDs as unsigned 64-bit integers (Discord user IDs
    // are snowflakes) - an arbitrary non-numeric string fails MLS leaf node
    // initialization.
    session.init(version: daveMaxSupportedProtocolVersion(), groupId: 1, selfUserId: '123456789012345678');

    // A lone session can generate its own key package (the "join request"
    // it would send via the voice gateway's MLS Key Package opcode), but
    // can't derive a key ratchet until it's actually part of an established
    // MLS group (i.e. after processing a commit/welcome) - that full
    // handshake is exercised by a dedicated multi-session integration test,
    // not this smoke test.
    final keyPackage = session.marshalledKeyPackage;
    expect(keyPackage, isNotEmpty);

    expect(failures, isEmpty);
  });

  test('encryptor and decryptor can be created and used in passthrough mode', () {
    final encryptor = DaveEncryptor();
    addTearDown(encryptor.dispose);
    expect(encryptor.hasKeyRatchet, isFalse);

    encryptor.passthroughMode = true;
    expect(encryptor.passthroughMode, isTrue);

    final frame = Uint8List.fromList(List.generate(64, (i) => i));
    final encryptResult = encryptor.encrypt(mediaType: DAVEMediaType.DAVE_MEDIA_TYPE_AUDIO, ssrc: 1234, frame: frame);
    expect(encryptResult.isSuccess, isTrue);
    expect(encryptResult.frame, equals(frame));

    final decryptor = DaveDecryptor();
    addTearDown(decryptor.dispose);
    decryptor.transitionToPassthroughMode(true);

    final decryptResult = decryptor.decrypt(
      mediaType: DAVEMediaType.DAVE_MEDIA_TYPE_AUDIO,
      encryptedFrame: encryptResult.frame,
    );
    expect(decryptResult.isSuccess, isTrue);
    expect(decryptResult.frame, equals(frame));
  });
}
