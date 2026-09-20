//! H264 encode via FFmpeg's VideoToolbox hwaccel (`h264_videotoolbox`).
//!
//! `ffmpeg-the-third`'s safe wrapper has no hw-frames-context support (see
//! this crate's README/design notes), so this module works directly against
//! `ffmpeg-sys-the-third`'s raw FFI, following the same
//! `AVHWDeviceContext`/`AVHWFramesContext` pattern FFmpeg's own C examples
//! use (there's no encode-side hwaccel example in FFmpeg's tree - this
//! mirrors `hw_decode.c`'s device/frames-context setup, applied to encoding).
//!
//! The key trick: our `CVPixelBuffer` came from AVFoundation, not from
//! FFmpeg's own hwframe pool, so instead of `av_hwframe_get_buffer` we build
//! one `AVFrame` per input frame that directly references our buffer -
//! `data[3]` holds the `CVPixelBufferRef` pointer (FFmpeg's own convention
//! for `AV_PIX_FMT_VIDEOTOOLBOX`), and `buf[0]` is an `AVBufferRef` with a
//! custom free callback that releases our retain when FFmpeg is done with
//! the frame. No pixel data is ever copied or read on the CPU side for this
//! path.

use std::ffi::CString;
use std::ptr;

use ffmpeg_the_third::ffi as sys;

use crate::api::types::EncodedVideoFrame;
use crate::capture::macos::RetainedPixelBuffer;

pub struct VideoToolboxEncoder {
    codec_ctx: *mut sys::AVCodecContext,
    hw_device_ctx: *mut sys::AVBufferRef,
    hw_frames_ctx: *mut sys::AVBufferRef,
    // `h264_videotoolbox` emits AVCC framing (4-byte NAL length prefixes,
    // SPS/PPS only in `codec_ctx->extradata`, never in-band) - this crate's
    // consumers (DAVE's `codec_utils.cpp` NAL parser, and the RTP
    // packetizer) both require Annex-B (start-code-delimited NALs, with
    // SPS/PPS repeated in-band before each keyframe), same as the old
    // openh264 encoder produced natively. `h264_mp4toannexb` does exactly
    // that conversion - see its use in `encode()`. Without it, DAVE still
    // "encrypts" something (it doesn't validate NAL structure up front) but
    // misidentifies which byte ranges are unencrypted, so the peer's AEAD
    // tag check fails on (almost) every frame - "Failed to finalize
    // decryption" / "no valid cryptor found" on the receiving end.
    bsf_ctx: *mut sys::AVBSFContext,
    width: u32,
    height: u32,
    pts: i64,
}

unsafe impl Send for VideoToolboxEncoder {}

impl VideoToolboxEncoder {
    pub fn create(width: u32, height: u32, fps: u32, bitrate_bps: u32) -> Result<Self, String> {
        unsafe {
            let mut hw_device_ctx: *mut sys::AVBufferRef = ptr::null_mut();
            let ret = sys::av_hwdevice_ctx_create(
                &mut hw_device_ctx,
                sys::AVHWDeviceType::VIDEOTOOLBOX as _,
                ptr::null(),
                ptr::null_mut(),
                0,
            );
            if ret < 0 {
                return Err(format!("av_hwdevice_ctx_create failed: {}", averror(ret)));
            }

            let encoder_name = CString::new("h264_videotoolbox").unwrap();
            let codec = sys::avcodec_find_encoder_by_name(encoder_name.as_ptr());
            if codec.is_null() {
                sys::av_buffer_unref(&mut hw_device_ctx);
                return Err("h264_videotoolbox encoder not found in this FFmpeg build".to_string());
            }

            let codec_ctx = sys::avcodec_alloc_context3(codec);
            if codec_ctx.is_null() {
                sys::av_buffer_unref(&mut hw_device_ctx);
                return Err("avcodec_alloc_context3 failed".to_string());
            }

            (*codec_ctx).width = width as i32;
            (*codec_ctx).height = height as i32;
            (*codec_ctx).time_base = sys::AVRational { num: 1, den: 90_000 };
            (*codec_ctx).framerate = sys::AVRational { num: fps as i32, den: 1 };
            (*codec_ctx).pix_fmt = sys::AVPixelFormat::VIDEOTOOLBOX;
            (*codec_ctx).gop_size = fps as i32; // one keyframe/sec, matches this crate's design notes
            (*codec_ctx).max_b_frames = 0; // real-time: no B-frame lookahead/reorder latency
            (*codec_ctx).bit_rate = bitrate_bps as i64;

            let hw_frames_ref = sys::av_hwframe_ctx_alloc(hw_device_ctx);
            if hw_frames_ref.is_null() {
                sys::avcodec_free_context(&mut { codec_ctx });
                sys::av_buffer_unref(&mut hw_device_ctx);
                return Err("av_hwframe_ctx_alloc failed".to_string());
            }
            let frames_ctx = (*hw_frames_ref).data as *mut sys::AVHWFramesContext;
            (*frames_ctx).format = sys::AVPixelFormat::VIDEOTOOLBOX;
            (*frames_ctx).sw_format = sys::AVPixelFormat::NV12;
            (*frames_ctx).width = width as i32;
            (*frames_ctx).height = height as i32;
            let ret = sys::av_hwframe_ctx_init(hw_frames_ref);
            if ret < 0 {
                let mut hw_frames_ref = hw_frames_ref;
                sys::av_buffer_unref(&mut hw_frames_ref);
                sys::avcodec_free_context(&mut { codec_ctx });
                sys::av_buffer_unref(&mut hw_device_ctx);
                return Err(format!("av_hwframe_ctx_init failed: {}", averror(ret)));
            }
            (*codec_ctx).hw_frames_ctx = sys::av_buffer_ref(hw_frames_ref);

            let ret = sys::avcodec_open2(codec_ctx, codec, ptr::null_mut());
            if ret < 0 {
                let mut hw_frames_ref = hw_frames_ref;
                sys::av_buffer_unref(&mut hw_frames_ref);
                sys::avcodec_free_context(&mut { codec_ctx });
                sys::av_buffer_unref(&mut hw_device_ctx);
                return Err(format!("avcodec_open2(h264_videotoolbox) failed: {}", averror(ret)));
            }

            // AVCC -> Annex-B, with in-band SPS/PPS - see this struct's
            // `bsf_ctx` doc for why this is required.
            let bsf_name = CString::new("h264_mp4toannexb").unwrap();
            let filter = sys::av_bsf_get_by_name(bsf_name.as_ptr());
            if filter.is_null() {
                let mut hw_frames_ref = hw_frames_ref;
                sys::av_buffer_unref(&mut hw_frames_ref);
                sys::avcodec_free_context(&mut { codec_ctx });
                sys::av_buffer_unref(&mut hw_device_ctx);
                return Err("h264_mp4toannexb bitstream filter not found in this FFmpeg build".to_string());
            }
            let mut bsf_ctx: *mut sys::AVBSFContext = ptr::null_mut();
            let ret = sys::av_bsf_alloc(filter, &mut bsf_ctx);
            if ret < 0 {
                let mut hw_frames_ref = hw_frames_ref;
                sys::av_buffer_unref(&mut hw_frames_ref);
                sys::avcodec_free_context(&mut { codec_ctx });
                sys::av_buffer_unref(&mut hw_device_ctx);
                return Err(format!("av_bsf_alloc failed: {}", averror(ret)));
            }
            let ret = sys::avcodec_parameters_from_context((*bsf_ctx).par_in, codec_ctx);
            if ret < 0 {
                sys::av_bsf_free(&mut bsf_ctx);
                let mut hw_frames_ref = hw_frames_ref;
                sys::av_buffer_unref(&mut hw_frames_ref);
                sys::avcodec_free_context(&mut { codec_ctx });
                sys::av_buffer_unref(&mut hw_device_ctx);
                return Err(format!("avcodec_parameters_from_context failed: {}", averror(ret)));
            }
            (*bsf_ctx).time_base_in = (*codec_ctx).time_base;
            let ret = sys::av_bsf_init(bsf_ctx);
            if ret < 0 {
                sys::av_bsf_free(&mut bsf_ctx);
                let mut hw_frames_ref = hw_frames_ref;
                sys::av_buffer_unref(&mut hw_frames_ref);
                sys::avcodec_free_context(&mut { codec_ctx });
                sys::av_buffer_unref(&mut hw_device_ctx);
                return Err(format!("av_bsf_init failed: {}", averror(ret)));
            }

            Ok(Self { codec_ctx, hw_device_ctx, hw_frames_ctx: hw_frames_ref, bsf_ctx, width, height, pts: 0 })
        }
    }

    /// Encodes one captured frame. `duration_micros` becomes this frame's PTS
    /// delta (90kHz clock, matching H264's fixed RTP clock rate - see
    /// `flutter_webrtc_rs`'s `write_packetized_frame` for why that rate is
    /// used end to end). Returns `Ok(None)` when the encoder buffered the
    /// frame internally without emitting a packet yet - normal, not an error.
    pub fn encode(&mut self, pixel_buffer: RetainedPixelBuffer, duration_micros: u64) -> Result<Option<EncodedVideoFrame>, String> {
        unsafe {
            let frame = sys::av_frame_alloc();
            if frame.is_null() {
                return Err("av_frame_alloc failed".to_string());
            }
            (*frame).format = sys::AVPixelFormat::VIDEOTOOLBOX.0;
            (*frame).width = self.width as i32;
            (*frame).height = self.height as i32;
            (*frame).pts = self.pts;
            self.pts += ((duration_micros as i64) * 90_000) / 1_000_000;

            // Transfer our retain to the AVFrame: wrap the raw CVPixelBufferRef
            // in an AVBufferRef whose free callback releases it, so FFmpeg
            // drops our reference exactly once, whenever it's actually done
            // with this frame (which may outlive this function, e.g. while
            // queued for encode).
            let raw_ptr = pixel_buffer.into_raw();
            let buf = sys::av_buffer_create(
                raw_ptr as *mut u8,
                std::mem::size_of::<usize>(),
                Some(release_pixel_buffer),
                raw_ptr as *mut std::ffi::c_void,
                0,
            );
            if buf.is_null() {
                RetainedPixelBuffer::release_raw(raw_ptr);
                sys::av_frame_free(&mut { frame });
                return Err("av_buffer_create failed".to_string());
            }
            (*frame).buf[0] = buf;
            (*frame).data[3] = raw_ptr as *mut u8;
            (*frame).hw_frames_ctx = sys::av_buffer_ref(self.hw_frames_ctx);

            let send_ret = sys::avcodec_send_frame(self.codec_ctx, frame);
            sys::av_frame_free(&mut { frame });
            if send_ret < 0 {
                return Err(format!("avcodec_send_frame failed: {}", averror(send_ret)));
            }

            let packet = sys::av_packet_alloc();
            if packet.is_null() {
                return Err("av_packet_alloc failed".to_string());
            }
            let recv_ret = sys::avcodec_receive_packet(self.codec_ctx, packet);
            if recv_ret == -(libc::EAGAIN) || recv_ret == sys::AVERROR_EOF {
                sys::av_packet_free(&mut { packet });
                return Ok(None); // encoder needs more input before it can emit a packet
            }
            if recv_ret < 0 {
                sys::av_packet_free(&mut { packet });
                return Err(format!("avcodec_receive_packet failed: {}", averror(recv_ret)));
            }

            // Convert AVCC -> Annex-B (and inject in-band SPS/PPS before
            // keyframes) - see `bsf_ctx`'s doc. `av_bsf_send_packet` takes
            // ownership of `packet`'s buffer and blanks it on success (and
            // leaves it untouched on error); either way it's safe/necessary
            // to free the packet struct itself right after.
            let send_ret = sys::av_bsf_send_packet(self.bsf_ctx, packet);
            sys::av_packet_free(&mut { packet });
            if send_ret < 0 {
                return Err(format!("av_bsf_send_packet failed: {}", averror(send_ret)));
            }

            let out_packet = sys::av_packet_alloc();
            if out_packet.is_null() {
                return Err("av_packet_alloc (bsf output) failed".to_string());
            }
            let bsf_recv_ret = sys::av_bsf_receive_packet(self.bsf_ctx, out_packet);
            if bsf_recv_ret < 0 {
                sys::av_packet_free(&mut { out_packet });
                if bsf_recv_ret == -(libc::EAGAIN) || bsf_recv_ret == sys::AVERROR_EOF {
                    return Ok(None);
                }
                return Err(format!("av_bsf_receive_packet failed: {}", averror(bsf_recv_ret)));
            }

            let data = std::slice::from_raw_parts((*out_packet).data, (*out_packet).size as usize).to_vec();
            let is_keyframe = ((*out_packet).flags & sys::AV_PKT_FLAG_KEY) != 0;
            sys::av_packet_free(&mut { out_packet });

            // Only keyframes carry an SPS (from h264_mp4toannexb's
            // extradata injection) - see `h264::rewrite_sps_in_annexb_frame`'s
            // doc for why this needs rewriting before DAVE/WebRTC ever see
            // it. Delta frames pass through this crate unmodified already
            // (no SPS to find), so skip the parse/rebuild for them.
            let data = if is_keyframe { crate::h264::rewrite_sps_in_annexb_frame(&data) } else { data };

            Ok(Some(EncodedVideoFrame {
                data,
                width: self.width,
                height: self.height,
                is_keyframe,
                duration_micros,
            }))
        }
    }
}

impl Drop for VideoToolboxEncoder {
    fn drop(&mut self) {
        unsafe {
            sys::av_bsf_free(&mut self.bsf_ctx);
            sys::avcodec_free_context(&mut self.codec_ctx);
            sys::av_buffer_unref(&mut self.hw_frames_ctx);
            sys::av_buffer_unref(&mut self.hw_device_ctx);
        }
    }
}

unsafe extern "C" fn release_pixel_buffer(_opaque: *mut std::ffi::c_void, data: *mut u8) {
    unsafe { RetainedPixelBuffer::release_raw(data as *mut objc2_core_video::CVBuffer) };
}

fn averror(code: i32) -> String {
    let mut buf = [0i8; 128];
    unsafe {
        ffmpeg_the_third::ffi::av_strerror(code, buf.as_mut_ptr(), buf.len());
        std::ffi::CStr::from_ptr(buf.as_ptr()).to_string_lossy().into_owned()
    }
}
