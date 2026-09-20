//! Platform-agnostic H264 Annex-B bitstream post-processing. Currently just
//! the SPS VUI rewrite (see `sps_vui_rewriter`) - split out from
//! `capture::macos::encode` since none of this touches AVFoundation/
//! VideoToolbox and every platform's encoder will need it.

mod sps_vui_rewriter;

pub use sps_vui_rewriter::rewrite_sps_in_annexb_frame;
