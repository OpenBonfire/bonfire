import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as pkg_ffi;

import 'dave_bindings_generated.dart';
import 'dave_bindings_generated.dart' as bindings;
import 'dave_session.dart';
import 'native_utils.dart';

final _encryptorDestroyFinalizer =
    ffi.NativeFinalizer(ffi.Native.addressOf<ffi.NativeFunction<ffi.Void Function(bindings.DAVEEncryptorHandle)>>(bindings.daveEncryptorDestroy).cast());

/// The result of a [DaveEncryptor.encrypt] call: the result code plus the
/// portion of the output buffer that was actually written.
class DaveEncryptResult {
  const DaveEncryptResult(this.code, this.frame);

  final DAVEEncryptorResultCode code;

  /// The encrypted frame bytes, valid only when
  /// `code == DAVEEncryptorResultCode.DAVE_ENCRYPTOR_RESULT_CODE_SUCCESS`.
  final Uint8List frame;

  bool get isSuccess => code == DAVEEncryptorResultCode.DAVE_ENCRYPTOR_RESULT_CODE_SUCCESS;
}

/// Encrypts outgoing media frames (one per SSRC you send) using a
/// [DaveKeyRatchet] derived from your own user id in the current
/// [DaveSession]. Must be [dispose]d.
class DaveEncryptor implements ffi.Finalizable {
  DaveEncryptor() : _handle = bindings.daveEncryptorCreate() {
    if (_handle == ffi.nullptr) throw StateError('daveEncryptorCreate returned null');
    _encryptorDestroyFinalizer.attach(this, _handle.cast(), detach: this);
  }

  final bindings.DAVEEncryptorHandle _handle;
  bool _disposed = false;

  void _checkNotDisposed() {
    if (_disposed) throw StateError('DaveEncryptor used after dispose()');
  }

  /// Sets the key ratchet used to derive per-frame keys. Does not take
  /// ownership - the [DaveKeyRatchet] must outlive this call and be
  /// disposed independently.
  void setKeyRatchet(DaveKeyRatchet keyRatchet) {
    _checkNotDisposed();
    bindings.daveEncryptorSetKeyRatchet(_handle, keyRatchet.handle);
  }

  /// While true, [encrypt] passes frames through unencrypted. Use this
  /// during the (brief) window before DAVE is fully negotiated, or when
  /// falling back to a non-DAVE call.
  bool get passthroughMode {
    _checkNotDisposed();
    return bindings.daveEncryptorIsPassthroughMode(_handle);
  }

  set passthroughMode(bool value) {
    _checkNotDisposed();
    bindings.daveEncryptorSetPassthroughMode(_handle, value);
  }

  void assignSsrcToCodec(int ssrc, DAVECodec codec) {
    _checkNotDisposed();
    bindings.daveEncryptorAssignSsrcToCodec(_handle, ssrc, codec);
  }

  int get protocolVersion {
    _checkNotDisposed();
    return bindings.daveEncryptorGetProtocolVersion(_handle);
  }

  bool get hasKeyRatchet {
    _checkNotDisposed();
    return bindings.daveEncryptorHasKeyRatchet(_handle);
  }

  int maxCiphertextSize(DAVEMediaType mediaType, int frameSize) {
    _checkNotDisposed();
    return bindings.daveEncryptorGetMaxCiphertextByteSize(_handle, mediaType, frameSize);
  }

  DAVEEncryptorStats getStats(DAVEMediaType mediaType) {
    _checkNotDisposed();
    final statsPtr = pkg_ffi.malloc<DAVEEncryptorStats>();
    try {
      bindings.daveEncryptorGetStats(_handle, mediaType, statsPtr);
      return statsPtr.ref;
    } finally {
      pkg_ffi.malloc.free(statsPtr);
    }
  }

  /// Encrypts one media frame for [ssrc]. Callers should route each RTP
  /// packet's payload through this before sending it, per SSRC/[mediaType].
  DaveEncryptResult encrypt({required DAVEMediaType mediaType, required int ssrc, required Uint8List frame}) {
    _checkNotDisposed();
    final capacity = maxCiphertextSize(mediaType, frame.length);

    final framePtr = allocateBytes(frame);
    final outPtr = pkg_ffi.malloc<ffi.Uint8>(capacity == 0 ? 1 : capacity);
    final writtenPtr = pkg_ffi.malloc<ffi.Size>();
    try {
      final code = bindings.daveEncryptorEncrypt(
        _handle,
        mediaType,
        ssrc,
        framePtr,
        frame.length,
        outPtr,
        capacity,
        writtenPtr,
      );
      final written = writtenPtr.value;
      final output = code == DAVEEncryptorResultCode.DAVE_ENCRYPTOR_RESULT_CODE_SUCCESS
          ? Uint8List.fromList(outPtr.asTypedList(written))
          : Uint8List(0);
      return DaveEncryptResult(code, output);
    } finally {
      pkg_ffi.malloc.free(framePtr);
      pkg_ffi.malloc.free(outPtr);
      pkg_ffi.malloc.free(writtenPtr);
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _encryptorDestroyFinalizer.detach(this);
    bindings.daveEncryptorDestroy(_handle);
  }
}
