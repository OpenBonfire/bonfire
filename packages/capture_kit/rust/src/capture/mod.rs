//! Platform capture backends - internal, not FRB-exposed directly (see
//! `crate::api::capture` for the Dart-facing surface). One `FrameSource` impl
//! per platform/source-type combination; today just macOS camera.

#[cfg(target_os = "macos")]
pub mod macos;

use crate::frb_generated::StreamSink;

use crate::api::types::{CaptureDeviceInfo, EncodedVideoFrame};

pub fn list_cameras() -> Result<Vec<CaptureDeviceInfo>, String> {
    #[cfg(target_os = "macos")]
    {
        macos::list_cameras()
    }
    #[cfg(not(target_os = "macos"))]
    {
        Err("camera capture is not yet implemented on this platform".to_string())
    }
}

/// Owns one capture-source-plus-encoder pipeline end to end - the
/// cross-platform side of `crate::api::capture::CameraCaptureSession`.
pub struct CaptureSession {
    #[cfg(target_os = "macos")]
    platform: macos::MacosCameraSession,
    #[cfg(not(target_os = "macos"))]
    _unimplemented: (),
}

impl CaptureSession {
    pub fn create_camera(device_id: Option<String>, width: u32, height: u32, fps: u32, bitrate_bps: u32) -> Result<Self, String> {
        #[cfg(target_os = "macos")]
        {
            Ok(Self { platform: macos::MacosCameraSession::create(device_id, width, height, fps, bitrate_bps)? })
        }
        #[cfg(not(target_os = "macos"))]
        {
            let _ = (device_id, width, height, fps, bitrate_bps);
            Err("camera capture is not yet implemented on this platform".to_string())
        }
    }

    pub fn start(&mut self, sink: StreamSink<EncodedVideoFrame>) -> Result<(), String> {
        #[cfg(target_os = "macos")]
        {
            self.platform.start(sink)
        }
        #[cfg(not(target_os = "macos"))]
        {
            let _ = sink;
            Err("camera capture is not yet implemented on this platform".to_string())
        }
    }

    pub fn stop(&mut self) {
        #[cfg(target_os = "macos")]
        {
            self.platform.stop();
        }
    }
}

