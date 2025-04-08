import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:webcrypto/webcrypto.dart';

class DiscordKeyPair {
  static Future<KeyPair<RsaOaepPrivateKey, RsaOaepPublicKey>>
      generateRsaKeyPair() async {
    KeyPair<RsaOaepPrivateKey, RsaOaepPublicKey> keyPair =
        await RsaOaepPrivateKey.generateKey(
      2048,
      // BigInt.from(3),
      BigInt.from(65537),
      Hash.sha256,
    );

    return keyPair;
  }

  static Future<String> serializePublicKey(
      KeyPair<RsaOaepPrivateKey, RsaOaepPublicKey> keyPair) async {
    Uint8List exportKey = await keyPair.publicKey.exportSpkiKey();

    return _btoa(exportKey);
  }

  static Future<String> publicKeyFingerprint(
      KeyPair<RsaOaepPrivateKey, RsaOaepPublicKey> keyPair) async {
    Uint8List exportKey = await keyPair.publicKey.exportSpkiKey();

    return _fingerprint(exportKey);
  }

  static Future<String> decryptEncodedCiphertext(
      KeyPair<RsaOaepPrivateKey, RsaOaepPublicKey> keyPair, String data) async {
    Uint8List bytes = await _Decrypt(keyPair, toByteArray(data));

    return utf8.decode(bytes);
  }

  static Future<String> decryptNonce(
      KeyPair<RsaOaepPrivateKey, RsaOaepPublicKey> keyPair, String data) async {
    Uint8List n = await _Decrypt(keyPair, toByteArray(data));

    return _serialize(n);
  }

  static Future<Map<String, String?>> decodeEncodedUserRecord(
      KeyPair<RsaOaepPrivateKey, RsaOaepPublicKey> keyPair, String data) async {
    String n = await decryptEncodedCiphertext(keyPair, data);

    final rx = RegExp(r"^(\d+):(\d{1,4}):([a-zA-Z0-9_]+):(.*)$");

    final match = rx.firstMatch(n);

    if (match == null) {
      return {};
    }

    return {
      "id": match[1],
      "discriminator": match[2],
      "avatar": "0" == match[3] ? null : match[3],
      "username": match[4]
    };
  }

  static Future<Uint8List> _Decrypt(
      KeyPair<RsaOaepPrivateKey, RsaOaepPublicKey> keyPair, Uint8List data) {
    return keyPair.privateKey.decryptBytes(data);
  }

  static String _btoa(Uint8List byteArray) {
    return base64.encode(byteArray);
  }

  static Uint8List _atob(String str) {
    Uint8List byteArray = base64.decode(str);

    return byteArray;
  }

  static String _serialize(Uint8List byteArray) {
    return _btoa(byteArray)
        .replaceAll(RegExp(r'\/'), "_")
        .replaceAll(RegExp(r'\+'), "-")
        .replaceAll(RegExp(r'={1,2}$'), "");
  }

  static Uint8List toByteArray(String str) {
    return _atob(str);
  }

  static Future<String> _fingerprint(Uint8List bytes) async {
    final digest = await Hash.sha256.digestBytes(bytes);

    return _serialize(digest);
  }
}
