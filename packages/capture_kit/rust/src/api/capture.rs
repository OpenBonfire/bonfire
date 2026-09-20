use std::sync::Mutex;

use flutter_rust_bridge::frb;
use crate::frb_generated::StreamSink;

use crate::api::types::{CaptureDeviceInfo, EncodedVideoFrame};

/// Enumerates cameras available to capture from on this device.
pub fn list_cameras() -> Result<Vec<CaptureDeviceInfo>, String> {
    crate::capture::list_cameras()
}

/// One active camera capture + hardware H264 encode session. Emits already-
/// encoded frames via [`start`](Self::start)'s `sink` - this crate knows
/// nothing about Discord/DAVE/RTP, the caller is expected to DAVE-encrypt
/// and send each frame itself (see `flutter_webrtc_rs`'s
/// `RtcMediaSender.writePacketizedFrame`).
#[frb(opaque)]
pub struct CameraCaptureSession {
    inner: Mutex<crate::capture::CaptureSession>,
}

impl CameraCaptureSession {
    /// `device_id` from [`list_cameras`], or `None` for the platform default.
    #[frb(sync)]
    pub fn create(device_id: Option<String>, width: u32, height: u32, fps: u32, bitrate_bps: u32) -> Result<CameraCaptureSession, String> {
        Ok(CameraCaptureSession {
            inner: Mutex::new(crate::capture::CaptureSession::create_camera(device_id, width, height, fps, bitrate_bps)?),
        })
    }

    pub async fn start(&self, sink: StreamSink<EncodedVideoFrame>) -> Result<(), String> {
        let mut inner = self.inner.lock().map_err(|_| "CameraCaptureSession: lock poisoned".to_string())?;
        inner.start(sink)
    }

    pub async fn stop(&self) -> Result<(), String> {
        let mut inner = self.inner.lock().map_err(|_| "CameraCaptureSession: lock poisoned".to_string())?;
        inner.stop();
        Ok(())
    }
}
