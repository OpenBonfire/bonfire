//! AVFoundation camera capture. Delivers frames on AVFoundation's own
//! delegate callback queue (a dedicated serial dispatch queue we create -
//! never the main thread), each as a retained `CVPixelBuffer` handle handed
//! straight to the caller with no format conversion or CPU copy - see this
//! module's parent doc for why (FFmpeg's VideoToolbox encoder wants exactly
//! this handle).

use std::sync::Mutex;

use dispatch2::DispatchQueue;
use objc2::rc::Retained;
use objc2::runtime::ProtocolObject;
use objc2::{define_class, msg_send, AnyThread, DefinedClass};
use objc2_av_foundation::{
    AVCaptureDevice, AVCaptureDeviceInput, AVCaptureOutput, AVCaptureSession,
    AVCaptureVideoDataOutput, AVCaptureVideoDataOutputSampleBufferDelegate, AVMediaTypeVideo,
};
use objc2_core_foundation::CFRetained;
use objc2_core_media::CMSampleBuffer;
use objc2_core_video::{kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, CVBuffer};
use objc2_foundation::{NSDictionary, NSNumber, NSObject, NSObjectProtocol, NSString};

use crate::api::types::CaptureDeviceInfo;

fn media_type_video() -> &'static NSString {
    unsafe { AVMediaTypeVideo }.expect("AVMediaTypeVideo is always non-null")
}

pub fn list_cameras() -> Result<Vec<CaptureDeviceInfo>, String> {
    #[allow(deprecated)]
    let devices = unsafe { AVCaptureDevice::devicesWithMediaType(media_type_video()) };
    Ok(devices
        .iter()
        .map(|device| CaptureDeviceInfo {
            id: unsafe { device.uniqueID() }.to_string(),
            name: unsafe { device.localizedName() }.to_string(),
        })
        .collect())
}

/// A `CVPixelBuffer` this crate holds its own retain on, via `CFRetained` -
/// `Send` because CoreVideo's own retain/release counting is atomic/thread-
/// safe, which is exactly what lets AVFoundation's capture queue hand a
/// buffer to our encode thread safely in the first place.
pub struct RetainedPixelBuffer {
    buffer: CFRetained<CVBuffer>,
}

unsafe impl Send for RetainedPixelBuffer {}

impl RetainedPixelBuffer {
    pub(crate) fn new(buffer: CFRetained<CVBuffer>) -> Self {
        Self { buffer }
    }

    /// Hands ownership of this crate's retain to the caller, as a raw
    /// pointer - for `crate::capture::macos::encode`, which transfers it
    /// again into an `AVBufferRef`'s custom free callback so FFmpeg
    /// releases it exactly once. Not a leak: the returned pointer carries
    /// the one retain `self` held.
    pub fn into_raw(self) -> *mut CVBuffer {
        CFRetained::into_raw(self.buffer).as_ptr()
    }

    /// The inverse of [`into_raw`](Self::into_raw) - reconstructs a
    /// `CFRetained` from a pointer that owns exactly one retain, so it gets
    /// released exactly once when dropped.
    pub unsafe fn release_raw(ptr: *mut CVBuffer) {
        drop(unsafe { CFRetained::from_raw(std::ptr::NonNull::new_unchecked(ptr)) });
    }
}

struct DelegateState {
    on_frame: Box<dyn FnMut(RetainedPixelBuffer) + Send>,
}

define_class!(
    #[unsafe(super(NSObject))]
    #[name = "CaptureKitSampleBufferDelegate"]
    #[ivars = Mutex<DelegateState>]
    struct SampleBufferDelegate;

    unsafe impl NSObjectProtocol for SampleBufferDelegate {}

    unsafe impl AVCaptureVideoDataOutputSampleBufferDelegate for SampleBufferDelegate {
        #[unsafe(method(captureOutput:didOutputSampleBuffer:fromConnection:))]
        unsafe fn capture_output_did_output_sample_buffer(
            &self,
            _output: &AVCaptureOutput,
            sample_buffer: &CMSampleBuffer,
            _connection: &objc2_av_foundation::AVCaptureConnection,
        ) {
            let Some(image_buffer) = (unsafe { sample_buffer.image_buffer() }) else {
                return;
            };
            let frame = RetainedPixelBuffer::new(image_buffer);

            let mut state = self.ivars().lock().unwrap();
            (state.on_frame)(frame);
        }
    }
);

pub struct AvFoundationCapture {
    session: Retained<AVCaptureSession>,
    output: Retained<AVCaptureVideoDataOutput>,
    delegate: Option<Retained<SampleBufferDelegate>>,
    width: u32,
    height: u32,
    fps: u32,
}

// `objc2` leaves ObjC objects `!Send`/`!Sync` by default since arbitrary
// classes aren't guaranteed thread-safe - but Apple explicitly documents
// AVCaptureSession/AVCaptureVideoDataOutput as safe to drive from a
// dedicated background thread (the standard AVFoundation pattern, and
// exactly what this module does: `start`/`stop` get called from whatever
// thread owns the `CameraCaptureSession`, not necessarily the thread that
// constructed it), and our own delegate only touches a `Mutex`-protected
// `DelegateState`. FRB's opaque-type wrapping requires the whole session to
// be `Send + Sync`.
unsafe impl Send for AvFoundationCapture {}
unsafe impl Sync for AvFoundationCapture {}

impl AvFoundationCapture {
    pub fn create(device_id: Option<String>, width: u32, height: u32, fps: u32) -> Result<Self, String> {
        let device = find_device(device_id.as_deref())?;

        let input = unsafe { AVCaptureDeviceInput::deviceInputWithDevice_error(&device) }
            .map_err(|error| format!("AVCaptureDeviceInput failed: {error:?}"))?;

        let session = unsafe { AVCaptureSession::new() };
        unsafe {
            session.beginConfiguration();
            if session.canAddInput(&input) {
                session.addInput(&input);
            } else {
                session.commitConfiguration();
                return Err("AVCaptureSession refused the camera input".to_string());
            }
        }

        let output = unsafe { AVCaptureVideoDataOutput::new() };
        unsafe {
            // NV12 (bi-planar 4:2:0) - VideoToolbox's own preferred encode
            // input format, so the encoder can wrap this buffer directly
            // with no pixel format conversion.
            //
            // "PixelFormatType" is `kCVPixelBufferPixelFormatTypeKey`'s
            // documented literal string value (CoreVideo.h) - built fresh as
            // an NSString rather than bridging objc2-core-video's CFString
            // constant, since NSDictionary keys compare by value (isEqual:),
            // not identity.
            let format_key = NSString::from_str("PixelFormatType");
            let format_value = NSNumber::new_u32(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as u32);
            let settings: Retained<NSDictionary<NSString, objc2::runtime::AnyObject>> =
                NSDictionary::from_slices(&[&*format_key], &[format_value.as_ref()]);
            output.setVideoSettings(Some(&settings));
            output.setAlwaysDiscardsLateVideoFrames(true);

            if session.canAddOutput(&output) {
                session.addOutput(&output);
            } else {
                session.commitConfiguration();
                return Err("AVCaptureSession refused the video data output".to_string());
            }
            session.commitConfiguration();
        }

        Ok(Self { session, output, delegate: None, width, height, fps })
    }

    pub fn width(&self) -> u32 {
        self.width
    }

    pub fn height(&self) -> u32 {
        self.height
    }

    pub fn fps(&self) -> u32 {
        self.fps
    }

    pub fn start(&mut self, on_frame: Box<dyn FnMut(RetainedPixelBuffer) + Send>) -> Result<(), String> {
        let delegate = SampleBufferDelegate::alloc().set_ivars(Mutex::new(DelegateState { on_frame }));
        let delegate: Retained<SampleBufferDelegate> = unsafe { msg_send![super(delegate), init] };

        let queue = DispatchQueue::new("com.openbonfire.capture_kit.camera", None);
        unsafe {
            self.output.setSampleBufferDelegate_queue(
                Some(&ProtocolObject::from_ref(&*delegate)),
                Some(&queue),
            );
            self.session.startRunning();
        }
        self.delegate = Some(delegate);
        Ok(())
    }

    pub fn stop(&mut self) {
        unsafe { self.session.stopRunning() };
        self.delegate = None;
    }
}

fn find_device(device_id: Option<&str>) -> Result<Retained<AVCaptureDevice>, String> {
    #[allow(deprecated)]
    let devices = unsafe { AVCaptureDevice::devicesWithMediaType(media_type_video()) };
    match device_id {
        Some(id) => devices
            .iter()
            .find(|device| unsafe { device.uniqueID() }.to_string() == id)
            .map(|device| device.clone())
            .ok_or_else(|| format!("no camera with id {id}")),
        None => {
            #[allow(deprecated)]
            let device = unsafe { AVCaptureDevice::defaultDeviceWithMediaType(media_type_video()) };
            device.ok_or_else(|| "no default camera available".to_string())
        }
    }
}
