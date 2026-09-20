//! Types shared across capture backends - see `crate::capture` (internal,
//! not FRB-exposed) for the `FrameSource` trait these describe the shape of.

/// One camera the current platform can capture from.
#[derive(Debug, Clone)]
pub struct CaptureDeviceInfo {
    /// Stable platform identifier - pass back to [`crate::api::capture::CameraCaptureSession::create`].
    pub id: String,
    pub name: String,
}

/// One encoded access unit (H264 Annex-B bytes - SPS+PPS+IDR-slice together
/// for a keyframe, just a slice for a delta frame) ready to hand to a DAVE
/// encryptor and RTP sender - see `flutter_webrtc_rs`'s
/// `RtcMediaSender::writePacketizedFrame`, which this is designed to feed
/// directly. This crate knows nothing about Discord, DAVE, or RTP - encoding
/// is where its responsibility ends.
#[derive(Debug, Clone)]
pub struct EncodedVideoFrame {
    pub data: Vec<u8>,
    pub width: u32,
    pub height: u32,
    pub is_keyframe: bool,
    /// Frame duration in microseconds, measured from the actual capture
    /// timestamps (not a nominal fixed value) - mirrors what the caller
    /// (`VoiceWebRtcRsSession`) already does for camera_macos frames today.
    pub duration_micros: u64,
}
