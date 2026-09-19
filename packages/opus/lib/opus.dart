/// Dart/Flutter FFI bindings for libopus (third_party/opus, vendored as a
/// git submodule, built from source by hook/build.dart - see that file and
/// the package README for platform support and build details).
///
/// Only the plain encoder/decoder API is wrapped - enough for real-time
/// voice (encode outgoing mic PCM, decode incoming packets per participant).
library;

export 'src/opus_codec.dart';
