# dave

Dart/Flutter FFI bindings for [Discord's libdave](https://github.com/discord/libdave),
the reference implementation of the DAVE protocol (end-to-end encryption for
Discord audio/video calls).

## Status

- **macOS: working end-to-end.** `dart test` builds libdave from source
  (via vcpkg + CMake), bundles it as a code asset, and exercises real MLS
  crypto (session init, key package generation) plus the encryptor/decryptor
  passthrough path.
- **iOS / Android / Linux / Windows: not yet implemented.** `hook/build.dart`
  only handles `OS.macOS` right now and throws a clear error for anything
  else - see "Adding another platform" below.
- Not yet wired into bonfire's voice controller. This package only provides
  the libdave bindings themselves; plumbing DAVE's MLS messages through the
  voice gateway opcodes and hooking `DaveEncryptor`/`DaveDecryptor` into
  flutter_webrtc's frame cryptor is separate, later work.

## Project structure

- `third_party/libdave` - libdave, vendored as a **git submodule**
  (`git submodule update --init --recursive` after cloning). Its own
  `cpp/vcpkg` submodule is vcpkg itself, used to build libdave's
  dependencies (OpenSSL, `nlohmann_json`, and `mlspp` - Cisco's MLS++,
  pulled in via a vcpkg overlay port since it isn't in the public registry).
- `third_party/libdave/cpp/includes/dave/dave.h` - libdave's own C API
  (opaque handles + plain C functions). This is the ffigen entry point;
  there's no hand-written shim, since libdave already ships a clean C API.
- `ffigen.yaml` / `lib/src/dave_bindings_generated.dart` - the generated raw
  bindings. Regenerate with `dart run ffigen --config ffigen.yaml` if
  `dave.h` changes (e.g. after bumping the libdave submodule).
- `hook/build.dart` - the native build hook (Dart's "native assets" /
  `package:hooks` mechanism, replacing the old per-platform
  CMakeLists.txt/podspec approach). Shells out to `cmake`/vcpkg to build
  libdave for the current build target, then registers the resulting shared
  library as the `package:dave/dave` code asset that the `@Native` bindings
  in `dave_bindings_generated.dart` resolve against at runtime.
- `lib/src/dave_session.dart`, `dave_encryptor.dart`, `dave_decryptor.dart` -
  the idiomatic Dart wrapper (handle lifecycle via explicit `dispose()` plus
  a `NativeFinalizer` safety net, byte buffer/string marshalling, callback
  bridging). `lib/dave.dart` is the public barrel export.

## Building and testing

```bash
git submodule update --init --recursive   # first time only
cd packages/dave
dart test
```

The first build compiles OpenSSL, `nlohmann_json`, and `mlspp` from source
via vcpkg for the host triplet - expect it to take several minutes. Later
builds are fast: vcpkg's binary cache (`~/.cache/vcpkg/archives`) is reused
across runs (and across different output directories/configs, since it's
keyed by package ABI hash, not build path).

## Regenerating bindings

```bash
dart run ffigen --config ffigen.yaml
```

Do this after bumping the `third_party/libdave` submodule to a version with
API changes.

## Adding another platform

`hook/build.dart`'s `_buildLibdave` switches on `input.config.code.targetOS`;
add a case there (mirroring `_buildForMacOS`) that:

1. Picks the right vcpkg triplet for the target
   (`arm64-android`/`x64-android`, `arm64-ios`/`arm64-ios-simulator`,
   `x64-linux`, `x64-windows`, ...). iOS/Android will need a chainloaded
   cross-compilation toolchain file (Xcode's for iOS, the NDK's
   `android.toolchain.cmake` for Android) passed via
   `VCPKG_CHAINLOAD_TOOLCHAIN_FILE`, same as libdave's own `wasm` Makefile
   target does for Emscripten.
2. Runs the same `cmake -B ... && cmake --build ... --target libdave && cmake
   --build ... --target install` sequence (note: libdave's CMakeLists.txt
   sets `CMAKE_SKIP_INSTALL_ALL_DEPENDENCY ON`, so the `libdave` target must
   be built explicitly before `install` - see the comment in
   `_buildForMacOS`).
3. Returns the path to the installed shared library
   (`<lib prefix>dave.<platform extension>`).

Verify with `dart test` (host platforms) or by depending on `dave` from a
Flutter app and running/building for the target platform.
