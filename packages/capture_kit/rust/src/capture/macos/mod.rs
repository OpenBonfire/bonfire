//! macOS camera capture (AVFoundation, via `objc2-av-foundation`) + hardware
//! H264 encode (FFmpeg's VideoToolbox hwaccel, via `ffmpeg-the-third`).
//!
//! Threading: AVFoundation delivers each frame on its own dedicated capture
//! queue (never the caller's thread, never Flutter's UI thread - see
//! `capture::AvFoundationCapture::create`). That callback hands the retained
//! `CVPixelBuffer` off through a bounded channel to one dedicated encode
//! thread per session, so a slow encode can never block AVFoundation's own
//! delivery queue. If the encoder falls behind, frames are dropped (logged)
//! rather than piling up unboundedly or stalling capture.

mod capture;
mod encode;

use std::sync::mpsc::{sync_channel, SyncSender, TrySendError};
use std::thread::JoinHandle;

use crate::frb_generated::StreamSink;

use crate::api::types::{CaptureDeviceInfo, EncodedVideoFrame};
pub use capture::RetainedPixelBuffer;

pub fn list_cameras() -> Result<Vec<CaptureDeviceInfo>, String> {
    capture::list_cameras()
}

/// Channel depth from the AVFoundation capture callback to the encode
/// thread - small on purpose: if the encoder is more than a couple of
/// frames behind, dropping is better than building unbounded latency.
const FRAME_CHANNEL_DEPTH: usize = 2;

pub struct MacosCameraSession {
    capture: capture::AvFoundationCapture,
    bitrate_bps: u32,
    encode_thread: Option<JoinHandle<()>>,
    frame_tx: Option<SyncSender<RetainedPixelBuffer>>,
}

impl MacosCameraSession {
    pub fn create(device_id: Option<String>, width: u32, height: u32, fps: u32, bitrate_bps: u32) -> Result<Self, String> {
        Ok(Self {
            capture: capture::AvFoundationCapture::create(device_id, width, height, fps)?,
            bitrate_bps,
            encode_thread: None,
            frame_tx: None,
        })
    }

    pub fn start(&mut self, sink: StreamSink<EncodedVideoFrame>) -> Result<(), String> {
        let width = self.capture.width();
        let height = self.capture.height();
        let fps = self.capture.fps();
        let bitrate_bps = self.bitrate_bps;

        let (frame_tx, frame_rx) = sync_channel::<RetainedPixelBuffer>(FRAME_CHANNEL_DEPTH);
        self.frame_tx = Some(frame_tx.clone());

        self.encode_thread = Some(std::thread::spawn(move || {
            let mut encoder = match encode::VideoToolboxEncoder::create(width, height, fps, bitrate_bps) {
                Ok(encoder) => encoder,
                Err(error) => {
                    log::error!("capture_kit: failed to create VideoToolbox encoder: {error}");
                    return;
                }
            };
            let mut last_frame_at: Option<std::time::Instant> = None;
            while let Ok(pixel_buffer) = frame_rx.recv() {
                let now = std::time::Instant::now();
                let duration_micros = last_frame_at
                    .map(|previous| now.duration_since(previous).as_micros() as u64)
                    .unwrap_or(1_000_000 / fps as u64);
                last_frame_at = Some(now);

                match encoder.encode(pixel_buffer, duration_micros) {
                    Ok(Some(frame)) => {
                        if sink.add(frame).is_err() {
                            break; // Dart side gone - stop encoding.
                        }
                    }
                    Ok(None) => {} // encoder buffered internally, nothing to emit yet
                    Err(error) => log::warn!("capture_kit: VideoToolbox encode failed: {error}"),
                }
            }
        }));

        self.capture.start(Box::new(move |pixel_buffer| {
            if let Err(TrySendError::Full(_)) = frame_tx.try_send(pixel_buffer) {
                log::debug!("capture_kit: encode thread behind, dropping a captured frame");
            }
        }))
    }

    pub fn stop(&mut self) {
        self.capture.stop();
        self.frame_tx.take(); // drop the sender - unblocks the encode thread's recv loop
        if let Some(handle) = self.encode_thread.take() {
            let _ = handle.join();
        }
    }
}

// Independent of any live camera/permissions: validates the actual new risk
// this crate adds - FFmpeg's VideoToolbox hwaccel encode path - with a
// synthetic NV12 `CVPixelBuffer` (built directly via CoreVideo, the same
// buffer shape AVFoundation's own capture delivers, see `capture.rs`'s
// module doc for why that shape matters), independently decoded with
// `openh264` (a different, unrelated H264 implementation to the one that
// encoded it) to confirm the produced bitstream is genuinely valid H264, not
// just self-consistent with this crate's own assumptions.
#[cfg(test)]
mod tests {
    use std::ptr::NonNull;

    use objc2_core_foundation::CFRetained;
    use objc2_core_video::{kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, CVPixelBufferCreate, CVPixelBufferLockBaseAddress, CVPixelBufferUnlockBaseAddress};

    use super::capture::RetainedPixelBuffer;
    use super::encode::VideoToolboxEncoder;
    use openh264::formats::YUVSource;

    const WIDTH: usize = 320;
    const HEIGHT: usize = 240;

    fn synthetic_nv12_frame() -> RetainedPixelBuffer {
        let mut raw: *mut objc2_core_video::CVPixelBuffer = std::ptr::null_mut();
        let status = unsafe {
            CVPixelBufferCreate(
                None,
                WIDTH,
                HEIGHT,
                kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                None,
                NonNull::new(&mut raw).unwrap(),
            )
        };
        assert_eq!(status, 0, "CVPixelBufferCreate failed");
        let buffer = unsafe { CFRetained::from_raw(NonNull::new(raw).unwrap()) };

        unsafe {
            CVPixelBufferLockBaseAddress(&buffer, objc2_core_video::CVPixelBufferLockFlags(0));
            let y_plane = objc2_core_video::CVPixelBufferGetBaseAddressOfPlane(&buffer, 0) as *mut u8;
            let y_stride = objc2_core_video::CVPixelBufferGetBytesPerRowOfPlane(&buffer, 0);
            for row in 0..HEIGHT {
                std::ptr::write_bytes(y_plane.add(row * y_stride), 120, WIDTH);
            }
            let uv_plane = objc2_core_video::CVPixelBufferGetBaseAddressOfPlane(&buffer, 1) as *mut u8;
            let uv_stride = objc2_core_video::CVPixelBufferGetBytesPerRowOfPlane(&buffer, 1);
            for row in 0..HEIGHT / 2 {
                std::ptr::write_bytes(uv_plane.add(row * uv_stride), 128, WIDTH);
            }
            CVPixelBufferUnlockBaseAddress(&buffer, objc2_core_video::CVPixelBufferLockFlags(0));
        }

        RetainedPixelBuffer::new(buffer)
    }

    #[test]
    fn videotoolbox_encoded_frame_is_valid_h264() {
        let mut encoder = VideoToolboxEncoder::create(WIDTH as u32, HEIGHT as u32, 15, 1_000_000).expect("create VideoToolbox encoder");
        let decoder = openh264::decoder::Decoder::new().expect("create openh264 decoder");
        let mut decoder = decoder;

        let mut decoded_dimensions = None;
        for _ in 0..10 {
            let frame = synthetic_nv12_frame();
            if let Some(encoded) = encoder.encode(frame, 1_000_000 / 15).expect("encode") {
                if let Some(picture) = decoder.decode(&encoded.data).expect("openh264 decode") {
                    let (width, height) = picture.dimensions();
                    decoded_dimensions = Some((width, height));
                    break;
                }
            }
        }

        let (width, height) = decoded_dimensions.expect("VideoToolbox never produced a frame openh264 could decode");
        assert_eq!(width, WIDTH);
        assert_eq!(height, HEIGHT);
    }
}
