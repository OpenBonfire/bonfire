import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as pkg_ffi;

import 'dave_bindings_generated.dart';
import 'dave_bindings_generated.dart' as bindings;
import 'dave_session.dart';
import 'native_utils.dart';

final _decryptorDestroyFinalizer =
    ffi.NativeFinalizer(ffi.Native.addressOf<ffi.NativeFunction<ffi.Void Function(bindings.DAVEDecryptorHandle)>>(bindings.daveDecryptorDestroy).cast());

/// The result of a [DaveDecryptor.decrypt] call: the result code plus the
/// portion of the output buffer that was actually written.
class DaveDecryptResult {
  const DaveDecryptResult(this.code, this.frame);

  final DAVEDecryptorResultCode code;

  /// The decrypted frame bytes, valid only when
  /// `code == DAVEDecryptorResultCode.DAVE_DECRYPTOR_RESULT_CODE_SUCCESS`.
  final Uint8List frame;

  bool get isSuccess => code == DAVEDecryptorResultCode.DAVE_DECRYPTOR_RESULT_CODE_SUCCESS;
}

/// Decrypts incoming media frames from one remote SSRC/participant, using a
/// [DaveKeyRatchet] derived from their user id in the current
/// [DaveSession]. Must be [dispose]d.
class DaveDecryptor implements ffi.Finalizable {
  DaveDecryptor() : _handle = bindings.daveDecryptorCreate() {
    if (_handle == ffi.nullptr) throw StateError('daveDecryptorCreate returned null');
    _decryptorDestroyFinalizer.attach(this, _handle.cast(), detach: this);
  }

  final bindings.DAVEDecryptorHandle _handle;
  bool _disposed = false;

  void _checkNotDisposed() {
    if (_disposed) throw StateError('DaveDecryptor used after dispose()');
  }

  /// Transitions to a new key ratchet (e.g. after an MLS epoch change).
  /// Does not take ownership - the [DaveKeyRatchet] must outlive this call
  /// and be disposed independently.
  void transitionToKeyRatchet(DaveKeyRatchet keyRatchet) {
    _checkNotDisposed();
    bindings.daveDecryptorTransitionToKeyRatchet(_handle, keyRatchet.handle);
  }

  /// While true, [decrypt] passes frames through unmodified - for the
  /// (brief) window before DAVE is fully negotiated, or a non-DAVE call.
  void transitionToPassthroughMode(bool passthroughMode) {
    _checkNotDisposed();
    bindings.daveDecryptorTransitionToPassthroughMode(_handle, passthroughMode);
  }

  int maxPlaintextSize(DAVEMediaType mediaType, int encryptedFrameSize) {
    _checkNotDisposed();
    return bindings.daveDecryptorGetMaxPlaintextByteSize(_handle, mediaType, encryptedFrameSize);
  }

  DAVEDecryptorStats getStats(DAVEMediaType mediaType) {
    _checkNotDisposed();
    final statsPtr = pkg_ffi.malloc<DAVEDecryptorStats>();
    try {
      bindings.daveDecryptorGetStats(_handle, mediaType, statsPtr);
      return statsPtr.ref;
    } finally {
      pkg_ffi.malloc.free(statsPtr);
    }
  }

  /// Decrypts one received media frame.
  DaveDecryptResult decrypt({required DAVEMediaType mediaType, required Uint8List encryptedFrame}) {
    _checkNotDisposed();
    final capacity = maxPlaintextSize(mediaType, encryptedFrame.length);

    final encryptedPtr = allocateBytes(encryptedFrame);
    final outPtr = pkg_ffi.malloc<ffi.Uint8>(capacity == 0 ? 1 : capacity);
    final writtenPtr = pkg_ffi.malloc<ffi.Size>();
    try {
      final code = bindings.daveDecryptorDecrypt(
        _handle,
        mediaType,
        encryptedPtr,
        encryptedFrame.length,
        outPtr,
        capacity,
        writtenPtr,
      );
      final written = writtenPtr.value;
      final output = code == DAVEDecryptorResultCode.DAVE_DECRYPTOR_RESULT_CODE_SUCCESS
          ? Uint8List.fromList(outPtr.asTypedList(written))
          : Uint8List(0);
      return DaveDecryptResult(code, output);
    } finally {
      pkg_ffi.malloc.free(encryptedPtr);
      pkg_ffi.malloc.free(outPtr);
      pkg_ffi.malloc.free(writtenPtr);
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _decryptorDestroyFinalizer.detach(this);
    bindings.daveDecryptorDestroy(_handle);
  }
}
