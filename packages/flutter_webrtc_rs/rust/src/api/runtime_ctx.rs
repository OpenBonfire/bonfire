//! The single process-wide async [`Runtime`] every `PeerConnection` is built with.
//!
//! webrtc-rs has no ambient runtime of its own - every internal call site takes an
//! explicit `&dyn Runtime` (see the crate's own docs), which is exactly what lets us
//! drive it from flutter_rust_bridge's async worker pool without that pool itself
//! being a Tokio reactor. We still need *a* real reactor for ICE/DTLS UDP sockets and
//! timers, so we resolve one real `Runtime` here (backed by Tokio, since `webrtc`'s
//! default features enable `runtime-tokio`) and hand the same `Arc` to every
//! `PeerConnectionBuilder::with_runtime` call.
use std::sync::{Arc, OnceLock};
use webrtc::runtime::{default_runtime, Runtime};

static RUNTIME: OnceLock<Arc<dyn Runtime>> = OnceLock::new();

/// Cheap to call repeatedly - clones a shared `Arc` rather than building a new runtime.
pub(crate) fn runtime() -> Arc<dyn Runtime> {
    Arc::clone(RUNTIME.get_or_init(|| {
        default_runtime().expect(
            "flutter_webrtc_rs_core: no async runtime available - `webrtc`'s runtime-tokio \
             feature (a default feature) should have provided one",
        )
    }))
}
