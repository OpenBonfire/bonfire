import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as pkg_ffi;

import 'dave_bindings_generated.dart' as bindings;
import 'native_utils.dart';

/// Called when the underlying MLS implementation hits a protocol failure
/// (e.g. a malformed or unverifiable commit/welcome). [source] identifies
/// the component that failed; [reason] is a human-readable explanation.
typedef DaveMlsFailureHandler = void Function(String source, String reason);

final _sessionDestroyFinalizer =
    ffi.NativeFinalizer(ffi.Native.addressOf<ffi.NativeFunction<ffi.Void Function(bindings.DAVESessionHandle)>>(bindings.daveSessionDestroy).cast());

/// A DAVE session: the per-call MLS group state used to derive per-sender
/// key ratchets for [DaveEncryptor]/[DaveDecryptor], and to process the
/// MLS commit/welcome/proposal messages Discord's voice gateway relays
/// (opcodes 24-31 - "MLS External Sender Package", "MLS Key Package", "MLS
/// Proposals", "MLS Commit Welcome", "MLS Welcome", etc).
///
/// Must be [dispose]d when done - this also happens automatically via a
/// [NativeFinalizer] if a [DaveSession] is garbage collected without being
/// disposed, but don't rely on that for timely cleanup of key material.
class DaveSession implements ffi.Finalizable {
  DaveSession({String? authSessionId, required DaveMlsFailureHandler onMlsFailure})
    : _onMlsFailure = onMlsFailure {
    _failureCallback = ffi.NativeCallable<bindings.DAVEMLSFailureCallbackFunction>.isolateLocal(
      _handleMlsFailure,
    );

    final authSessionIdPtr = authSessionId == null ? ffi.nullptr : allocateString(authSessionId);
    try {
      _handle = bindings.daveSessionCreate(
        ffi.nullptr,
        authSessionIdPtr,
        _failureCallback.nativeFunction,
        ffi.nullptr,
      );
    } finally {
      if (authSessionIdPtr != ffi.nullptr) pkg_ffi.malloc.free(authSessionIdPtr);
    }

    if (_handle == ffi.nullptr) {
      _failureCallback.close();
      throw StateError('daveSessionCreate returned null');
    }

    _sessionDestroyFinalizer.attach(this, _handle.cast(), detach: this);
  }

  final DaveMlsFailureHandler _onMlsFailure;
  late final ffi.NativeCallable<bindings.DAVEMLSFailureCallbackFunction> _failureCallback;
  late final bindings.DAVESessionHandle _handle;
  bool _disposed = false;

  void _handleMlsFailure(ffi.Pointer<ffi.Char> source, ffi.Pointer<ffi.Char> reason, ffi.Pointer<ffi.Void> userData) {
    _onMlsFailure(readString(source), readString(reason));
  }

  void _checkNotDisposed() {
    if (_disposed) throw StateError('DaveSession used after dispose()');
  }

  /// Initializes the session for group [groupId] as [selfUserId], using
  /// protocol [version] (see [maxSupportedProtocolVersion]).
  void init({required int version, required int groupId, required String selfUserId}) {
    _checkNotDisposed();
    final userIdPtr = allocateString(selfUserId);
    try {
      bindings.daveSessionInit(_handle, version, groupId, userIdPtr);
    } finally {
      pkg_ffi.malloc.free(userIdPtr);
    }
  }

  void reset() {
    _checkNotDisposed();
    bindings.daveSessionReset(_handle);
  }

  int get protocolVersion {
    _checkNotDisposed();
    return bindings.daveSessionGetProtocolVersion(_handle);
  }

  set protocolVersion(int version) {
    _checkNotDisposed();
    bindings.daveSessionSetProtocolVersion(_handle, version);
  }

  /// The authenticator for the last MLS epoch - used to confirm all
  /// participants agree on the current group state (Discord's "voice
  /// privacy code" / identity verification is built on this).
  Uint8List get lastEpochAuthenticator {
    _checkNotDisposed();
    final outPtr = pkg_ffi.malloc<ffi.Pointer<ffi.Uint8>>();
    final outLen = pkg_ffi.malloc<ffi.Size>();
    try {
      bindings.daveSessionGetLastEpochAuthenticator(_handle, outPtr, outLen);
      return copyAndFreeBytes(outPtr.value, outLen.value);
    } finally {
      pkg_ffi.malloc.free(outPtr);
      pkg_ffi.malloc.free(outLen);
    }
  }

  /// Sets the external sender credential - received from the voice gateway
  /// as "MLS External Sender Package" (opcode 25) and required before any
  /// commit/proposal can be processed.
  void setExternalSender(Uint8List externalSender) {
    _checkNotDisposed();
    final ptr = allocateBytes(externalSender);
    try {
      bindings.daveSessionSetExternalSender(_handle, ptr, externalSender.length);
    } finally {
      pkg_ffi.malloc.free(ptr);
    }
  }

  /// Processes MLS proposals (as relayed by the voice gateway's "MLS
  /// Proposals" opcode) and returns the resulting commit/welcome message to
  /// send back via "MLS Commit Welcome". [recognizedUserIds] should be the
  /// set of user IDs currently known to be in the call.
  Uint8List processProposals(Uint8List proposals, List<String> recognizedUserIds) {
    _checkNotDisposed();
    final proposalsPtr = allocateBytes(proposals);
    final (userIdsPtr, userIdPointers) = _allocateStringArray(recognizedUserIds);
    final outPtr = pkg_ffi.malloc<ffi.Pointer<ffi.Uint8>>();
    final outLen = pkg_ffi.malloc<ffi.Size>();
    try {
      bindings.daveSessionProcessProposals(
        _handle,
        proposalsPtr,
        proposals.length,
        userIdsPtr,
        recognizedUserIds.length,
        outPtr,
        outLen,
      );
      return copyAndFreeBytes(outPtr.value, outLen.value);
    } finally {
      pkg_ffi.malloc.free(proposalsPtr);
      _freeStringArray(userIdsPtr, userIdPointers);
      pkg_ffi.malloc.free(outPtr);
      pkg_ffi.malloc.free(outLen);
    }
  }

  /// Processes an incoming MLS commit (voice gateway "MLS Commit Welcome"
  /// or "MLS Announce Commit Transition"). The result must be [dispose]d.
  DaveCommitResult processCommit(Uint8List commit) {
    _checkNotDisposed();
    final ptr = allocateBytes(commit);
    try {
      final handle = bindings.daveSessionProcessCommit(_handle, ptr, commit.length);
      if (handle == ffi.nullptr) throw StateError('daveSessionProcessCommit returned null');
      return DaveCommitResult._(handle);
    } finally {
      pkg_ffi.malloc.free(ptr);
    }
  }

  /// Processes an incoming MLS welcome message (voice gateway "MLS
  /// Welcome") to join the group. The result must be [dispose]d.
  DaveWelcomeResult processWelcome(Uint8List welcome, List<String> recognizedUserIds) {
    _checkNotDisposed();
    final ptr = allocateBytes(welcome);
    final (userIdsPtr, userIdPointers) = _allocateStringArray(recognizedUserIds);
    try {
      final handle = bindings.daveSessionProcessWelcome(
        _handle,
        ptr,
        welcome.length,
        userIdsPtr,
        recognizedUserIds.length,
      );
      if (handle == ffi.nullptr) throw StateError('daveSessionProcessWelcome returned null');
      return DaveWelcomeResult._(handle);
    } finally {
      pkg_ffi.malloc.free(ptr);
      _freeStringArray(userIdsPtr, userIdPointers);
    }
  }

  /// The marshalled MLS key package for this session - sent to the voice
  /// gateway as "MLS Key Package" (opcode 26) so other members can add us
  /// to the group.
  Uint8List get marshalledKeyPackage {
    _checkNotDisposed();
    final outPtr = pkg_ffi.malloc<ffi.Pointer<ffi.Uint8>>();
    final outLen = pkg_ffi.malloc<ffi.Size>();
    try {
      bindings.daveSessionGetMarshalledKeyPackage(_handle, outPtr, outLen);
      return copyAndFreeBytes(outPtr.value, outLen.value);
    } finally {
      pkg_ffi.malloc.free(outPtr);
      pkg_ffi.malloc.free(outLen);
    }
  }

  /// The key ratchet used to derive [userId]'s per-frame encryption keys -
  /// feed this to a [DaveDecryptor] for their stream (or, for our own user
  /// id, to a [DaveEncryptor]). Must be [dispose]d.
  DaveKeyRatchet getKeyRatchet(String userId) {
    _checkNotDisposed();
    final ptr = allocateString(userId);
    try {
      final handle = bindings.daveSessionGetKeyRatchet(_handle, ptr);
      if (handle == ffi.nullptr) throw StateError('daveSessionGetKeyRatchet($userId) returned null');
      return DaveKeyRatchet._(handle);
    } finally {
      pkg_ffi.malloc.free(ptr);
    }
  }

  /// Computes the pairwise fingerprint used for out-of-band identity
  /// verification with [userId] (Discord's "voice privacy code" comparison
  /// UI is built on this).
  Future<Uint8List> getPairwiseFingerprint({required int version, required String userId}) {
    _checkNotDisposed();
    final completer = Completer<Uint8List>();
    late final ffi.NativeCallable<bindings.DAVEPairwiseFingerprintCallbackFunction> callback;
    callback = ffi.NativeCallable<bindings.DAVEPairwiseFingerprintCallbackFunction>.isolateLocal(
      (ffi.Pointer<ffi.Uint8> fingerprint, int length, ffi.Pointer<ffi.Void> userData) {
        completer.complete(copyBytes(fingerprint, length));
        // Freed by this call returning per dave.h's callback contract - not
        // via daveFree (it's a stack/temporary buffer owned by the library
        // for the duration of the callback only).
        callback.close();
      },
    );

    final userIdPtr = allocateString(userId);
    try {
      bindings.daveSessionGetPairwiseFingerprint(_handle, version, userIdPtr, callback.nativeFunction, ffi.nullptr);
    } finally {
      pkg_ffi.malloc.free(userIdPtr);
    }
    return completer.future;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _sessionDestroyFinalizer.detach(this);
    bindings.daveSessionDestroy(_handle);
    _failureCallback.close();
  }
}

(ffi.Pointer<ffi.Pointer<ffi.Char>>, List<ffi.Pointer<ffi.Char>>) _allocateStringArray(List<String> values) {
  final pointers = values.map(allocateString).toList(growable: false);
  if (pointers.isEmpty) return (ffi.nullptr, pointers);
  final array = pkg_ffi.malloc<ffi.Pointer<ffi.Char>>(pointers.length);
  for (var i = 0; i < pointers.length; i++) {
    array[i] = pointers[i];
  }
  return (array, pointers);
}

void _freeStringArray(ffi.Pointer<ffi.Pointer<ffi.Char>> array, List<ffi.Pointer<ffi.Char>> pointers) {
  for (final pointer in pointers) {
    pkg_ffi.malloc.free(pointer);
  }
  if (array != ffi.nullptr) pkg_ffi.malloc.free(array);
}

final _keyRatchetDestroyFinalizer =
    ffi.NativeFinalizer(ffi.Native.addressOf<ffi.NativeFunction<ffi.Void Function(bindings.DAVEKeyRatchetHandle)>>(bindings.daveKeyRatchetDestroy).cast());

/// A per-sender key ratchet, obtained from [DaveSession.getKeyRatchet].
/// Feed it into a [DaveEncryptor] (for the local user) or [DaveDecryptor]
/// (for a remote user) to actually encrypt/decrypt media frames with it.
class DaveKeyRatchet implements ffi.Finalizable {
  DaveKeyRatchet._(this._handle) {
    _keyRatchetDestroyFinalizer.attach(this, _handle.cast(), detach: this);
  }

  final bindings.DAVEKeyRatchetHandle _handle;
  bool _disposed = false;

  bindings.DAVEKeyRatchetHandle get handle {
    if (_disposed) throw StateError('DaveKeyRatchet used after dispose()');
    return _handle;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _keyRatchetDestroyFinalizer.detach(this);
    bindings.daveKeyRatchetDestroy(_handle);
  }
}

final _commitResultDestroyFinalizer =
    ffi.NativeFinalizer(ffi.Native.addressOf<ffi.NativeFunction<ffi.Void Function(bindings.DAVECommitResultHandle)>>(bindings.daveCommitResultDestroy).cast());

/// The result of [DaveSession.processCommit].
class DaveCommitResult implements ffi.Finalizable {
  DaveCommitResult._(this._handle) {
    _commitResultDestroyFinalizer.attach(this, _handle.cast(), detach: this);
  }

  final bindings.DAVECommitResultHandle _handle;
  bool _disposed = false;

  void _checkNotDisposed() {
    if (_disposed) throw StateError('DaveCommitResult used after dispose()');
  }

  bool get isFailed {
    _checkNotDisposed();
    return bindings.daveCommitResultIsFailed(_handle);
  }

  bool get isIgnored {
    _checkNotDisposed();
    return bindings.daveCommitResultIsIgnored(_handle);
  }

  /// The member IDs in the roster after this commit was applied.
  List<int> get rosterMemberIds {
    _checkNotDisposed();
    final outPtr = pkg_ffi.malloc<ffi.Pointer<ffi.Uint64>>();
    final outLen = pkg_ffi.malloc<ffi.Size>();
    try {
      bindings.daveCommitResultGetRosterMemberIds(_handle, outPtr, outLen);
      return copyAndFreeUint64List(outPtr.value, outLen.value);
    } finally {
      pkg_ffi.malloc.free(outPtr);
      pkg_ffi.malloc.free(outLen);
    }
  }

  Uint8List getRosterMemberSignature(int rosterId) {
    _checkNotDisposed();
    final outPtr = pkg_ffi.malloc<ffi.Pointer<ffi.Uint8>>();
    final outLen = pkg_ffi.malloc<ffi.Size>();
    try {
      bindings.daveCommitResultGetRosterMemberSignature(_handle, rosterId, outPtr, outLen);
      return copyAndFreeBytes(outPtr.value, outLen.value);
    } finally {
      pkg_ffi.malloc.free(outPtr);
      pkg_ffi.malloc.free(outLen);
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _commitResultDestroyFinalizer.detach(this);
    bindings.daveCommitResultDestroy(_handle);
  }
}

final _welcomeResultDestroyFinalizer =
    ffi.NativeFinalizer(ffi.Native.addressOf<ffi.NativeFunction<ffi.Void Function(bindings.DAVEWelcomeResultHandle)>>(bindings.daveWelcomeResultDestroy).cast());

/// The result of [DaveSession.processWelcome].
class DaveWelcomeResult implements ffi.Finalizable {
  DaveWelcomeResult._(this._handle) {
    _welcomeResultDestroyFinalizer.attach(this, _handle.cast(), detach: this);
  }

  final bindings.DAVEWelcomeResultHandle _handle;
  bool _disposed = false;

  void _checkNotDisposed() {
    if (_disposed) throw StateError('DaveWelcomeResult used after dispose()');
  }

  /// The member IDs in the roster from the welcome message.
  List<int> get rosterMemberIds {
    _checkNotDisposed();
    final outPtr = pkg_ffi.malloc<ffi.Pointer<ffi.Uint64>>();
    final outLen = pkg_ffi.malloc<ffi.Size>();
    try {
      bindings.daveWelcomeResultGetRosterMemberIds(_handle, outPtr, outLen);
      return copyAndFreeUint64List(outPtr.value, outLen.value);
    } finally {
      pkg_ffi.malloc.free(outPtr);
      pkg_ffi.malloc.free(outLen);
    }
  }

  Uint8List getRosterMemberSignature(int rosterId) {
    _checkNotDisposed();
    final outPtr = pkg_ffi.malloc<ffi.Pointer<ffi.Uint8>>();
    final outLen = pkg_ffi.malloc<ffi.Size>();
    try {
      bindings.daveWelcomeResultGetRosterMemberSignature(_handle, rosterId, outPtr, outLen);
      return copyAndFreeBytes(outPtr.value, outLen.value);
    } finally {
      pkg_ffi.malloc.free(outPtr);
      pkg_ffi.malloc.free(outLen);
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _welcomeResultDestroyFinalizer.detach(this);
    bindings.daveWelcomeResultDestroy(_handle);
  }
}
