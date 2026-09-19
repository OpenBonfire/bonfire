import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as pkg_ffi;

import 'dave_bindings_generated.dart' as bindings;

/// Copies [bytes] into a newly `malloc`-allocated buffer. The caller owns
/// the result and must free it (typically right after the native call that
/// consumes it returns, since libdave's API docs state functions "do not
/// take ownership of the input data unless otherwise specified").
ffi.Pointer<ffi.Uint8> allocateBytes(Uint8List bytes) {
  final pointer = pkg_ffi.malloc<ffi.Uint8>(bytes.isEmpty ? 1 : bytes.length);
  pointer.asTypedList(bytes.length).setAll(0, bytes);
  return pointer;
}

/// Copies a native `uint8_t*`/`length` pair (as produced by an `[out]`
/// parameter pair in dave.h, e.g. `daveSessionGetMarshalledKeyPackage`) into
/// a Dart [Uint8List], then frees the native buffer with `daveFree`.
Uint8List copyAndFreeBytes(ffi.Pointer<ffi.Uint8> pointer, int length) {
  if (pointer == ffi.nullptr || length == 0) return Uint8List(0);
  final copy = Uint8List.fromList(pointer.asTypedList(length));
  bindings.daveFree(pointer.cast());
  return copy;
}

/// Copies a native `uint8_t*`/`length` pair WITHOUT freeing it - for the
/// handful of dave.h callbacks documented as owning and freeing their own
/// buffer after the callback returns (unlike the `daveFree`-owned `[out]`
/// parameters above), e.g. `DAVEPairwiseFingerprintCallback`.
Uint8List copyBytes(ffi.Pointer<ffi.Uint8> pointer, int length) {
  if (pointer == ffi.nullptr || length == 0) return Uint8List(0);
  return Uint8List.fromList(pointer.asTypedList(length));
}

/// Copies a native `uint64_t*`/`length` pair (e.g. roster member ID arrays)
/// into a Dart [List], then frees the native buffer with `daveFree`.
List<int> copyAndFreeUint64List(ffi.Pointer<ffi.Uint64> pointer, int length) {
  if (pointer == ffi.nullptr || length == 0) return const [];
  final copy = List<int>.of(pointer.asTypedList(length));
  bindings.daveFree(pointer.cast());
  return copy;
}

/// Converts [value] to a `malloc`-allocated, NUL-terminated UTF-8 buffer.
/// The caller owns the result and must free it.
ffi.Pointer<ffi.Char> allocateString(String value) => value.toNativeUtf8(allocator: pkg_ffi.malloc).cast();

/// Reads a NUL-terminated UTF-8 native string. Does not take ownership -
/// does not free [pointer].
String readString(ffi.Pointer<ffi.Char> pointer, {int? length}) {
  if (pointer == ffi.nullptr) return '';
  if (length != null) return utf8.decode(pointer.cast<ffi.Uint8>().asTypedList(length));
  return pointer.cast<pkg_ffi.Utf8>().toDartString();
}
