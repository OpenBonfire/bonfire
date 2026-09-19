/// Dart bindings for Discord's libdave - the DAVE protocol library providing
/// end-to-end encryption (E2EE) for Discord audio/video calls.
///
/// libdave (third_party/libdave, vendored as a git submodule) is built from
/// source via CMake + vcpkg by hook/build.dart; see that file and the
/// package README for how the native build works and which platforms are
/// currently supported.
///
/// Typical usage for a voice call:
/// 1. Create a [DaveSession], [DaveSession.init] it with the group/version
///    info from the voice gateway's Ready/Session Description, and feed it
///    the MLS messages the gateway relays (external sender, proposals,
///    commits, welcomes - see the opcodes referenced on [DaveSession]).
/// 2. For your own outgoing media, get your key ratchet with
///    [DaveSession.getKeyRatchet], give it to a [DaveEncryptor], and call
///    [DaveEncryptor.encrypt] per outgoing frame.
/// 3. For each remote participant's incoming media, get their key ratchet
///    and give it to a per-participant [DaveDecryptor], calling
///    [DaveDecryptor.decrypt] per incoming frame.
///
/// All native handles (`DaveSession`, `DaveKeyRatchet`, `DaveEncryptor`,
/// `DaveDecryptor`, `DaveCommitResult`, `DaveWelcomeResult`) must be
/// disposed when done.
library;

export 'src/dave_bindings_generated.dart'
    show
        DAVECodec,
        DAVEMediaType,
        DAVEEncryptorResultCode,
        DAVEDecryptorResultCode,
        DAVELoggingSeverity,
        DAVEEncryptorStats,
        DAVEDecryptorStats,
        daveMaxSupportedProtocolVersion,
        daveSetLogSinkCallback;
export 'src/dave_decryptor.dart';
export 'src/dave_encryptor.dart';
export 'src/dave_session.dart';
