pub mod data_channel;
pub mod media;
pub mod peer_connection;
// Not `pub`: this is an internal helper (the shared `Arc<dyn Runtime>` every
// `PeerConnection` is built with), not part of the Dart-facing API. Keeping it
// non-public keeps flutter_rust_bridge_codegen from trying to generate bindings for
// `webrtc::runtime::Runtime` (a trait object it has no reason to expose).
pub(crate) mod runtime_ctx;
pub mod types;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
