//! H264 encode/decode, using [openh264](https://github.com/ralfbiedert/openh264-rs)
//! (built from source - no system library, no precompiled-binary licensing
//! question, just a `cc` build like any other vendored C dependency).
//!
//! Kept in this crate rather than pushed out to the caller, unlike the pure
//! packetize/depacketize transport work elsewhere in `api/` - see this crate's
//! README for the reasoning update (codecs are in scope here, capture and
//! rendering are not).
//!
//! [`H264Encoder::encode_bgra8`] takes one BGRA8 camera frame (the pixel format
//! macOS camera capture APIs hand out) and returns an Annex-B encoded frame -
//! feed that straight to [`crate::api::media::RtcMediaSender::write_encoded_frame`].
//! [`H264Decoder::decode`] takes RTP-depacketized H264 bytes (already reassembled
//! across any FU-A fragmentation - see
//! [`crate::api::media::RtcRemoteTrack::packets`]) and returns a decoded RGB8
//! frame once a full picture is available.
use std::sync::Mutex;

use flutter_rust_bridge::frb;
use openh264::decoder::Decoder;
use openh264::encoder::{BitRate, Encoder, EncoderConfig, IntraFramePeriod};
use openh264::formats::{BgraSliceU8, RgbaSliceU8, YUVBuffer, YUVSource};
use openh264::OpenH264API;

/// One decoded video frame, RGB8 (3 bytes/pixel, row-major, no padding).
#[derive(Debug, Clone)]
pub struct DecodedVideoFrame {
    pub width: u32,
    pub height: u32,
    pub rgb: Vec<u8>,
}

#[frb(opaque)]
pub struct H264Encoder {
    // openh264's `Encoder::encode` takes `&mut self`; FRB opaque methods take
    // `&self` (the handle is shared behind an `Arc`), so interior mutability is
    // needed regardless of any actual cross-thread contention - encode calls are
    // expected to come from one mic/camera-feeding task at a time.
    inner: Mutex<Encoder>,
}

impl H264Encoder {
    /// `bitrate_bps` is a target, not a hard cap - openh264's rate control will
    /// exceed it somewhat on complex frames.
    ///
    /// Configures a periodic keyframe every 15 frames (~1s at this crate's
    /// nominal 15fps capture rate) - openh264 defaults to *never* emitting
    /// another IDR after the very first frame
    /// (`IntraFramePeriod::from_num_frames(0)`, its "disable periodic intra
    /// frames" default). Without this, losing or missing that one startup
    /// keyframe (e.g. because DAVE's MLS handshake hadn't finished yet, so
    /// the very first frames get dropped rather than sent - see the caller's
    /// send loop) means a receiver can never recover for the rest of the
    /// call: there's no RTCP PLI/FIR handling in this crate yet to request
    /// one on demand (see [`force_intra_frame`](Self::force_intra_frame) for
    /// forcing one manually once that lands), so a fixed interval is the
    /// only recovery mechanism available today. This matches what a known-
    /// working reference implementation
    /// (github.com/Discord-RE/Discord-video-stream) does explicitly via
    /// ffmpeg's `-force_key_frames expr:gte(t,n_forced*1)` (also every 1s).
    pub fn create(bitrate_bps: u32) -> Result<H264Encoder, String> {
        let api = OpenH264API::from_source();
        let config = EncoderConfig::new()
            .bitrate(BitRate::from_bps(bitrate_bps))
            .intra_frame_period(IntraFramePeriod::from_num_frames(15));
        let encoder = Encoder::with_api_config(api, config).map_err(|e| e.to_string())?;
        Ok(H264Encoder { inner: Mutex::new(encoder) })
    }

    /// Forces the *next* `encode_bgra8`/`encode_rgba8` call to produce a
    /// fresh IDR keyframe, regardless of the periodic interval configured in
    /// [`create`](Self::create). For manually recovering a stream (e.g. once
    /// this crate reads inbound RTCP PLI/FIR and wants to react to it) -
    /// unused by anything in this crate today.
    pub fn force_intra_frame(&self) -> Result<(), String> {
        let mut encoder = self.inner.lock().map_err(|_| "H264Encoder: lock poisoned".to_string())?;
        encoder.force_intra_frame();
        Ok(())
    }

    /// Encodes one frame from BGRA8 pixel data (row-major, no padding -
    /// `width * height * 4` bytes). This is the pixel format macOS/iOS camera
    /// capture (`AVCaptureVideoDataOutput` with `kCVPixelFormatType_32BGRA`,
    /// what most Flutter camera plugins hand out on those platforms) uses
    /// natively, so no format conversion is needed on the Dart side.
    ///
    /// Returns Annex-B bytes (one or more NAL units, start-code-prefixed) -
    /// openh264 may emit SPS/PPS NALs ahead of the slice NAL on keyframes, all
    /// concatenated in this one buffer; `write_encoded_frame` and the RTP H264
    /// payloader downstream handle that transparently.
    pub fn encode_bgra8(&self, data: Vec<u8>, width: u32, height: u32) -> Result<Vec<u8>, String> {
        let expected_len = (width as usize) * (height as usize) * 4;
        if data.len() != expected_len {
            return Err(format!(
                "encode_bgra8: expected {expected_len} bytes for {width}x{height} BGRA8, got {}",
                data.len()
            ));
        }
        let source = BgraSliceU8::new(&data, (width as usize, height as usize));
        let yuv = YUVBuffer::from_bgra8_source(source);
        let mut encoder = self.inner.lock().map_err(|_| "H264Encoder: lock poisoned".to_string())?;
        let bitstream = encoder.encode(&yuv).map_err(|e| e.to_string())?;
        Ok(bitstream.to_vec())
    }

    /// As [`encode_bgra8`](Self::encode_bgra8), for RGBA8 sources instead (some
    /// non-Apple capture paths use this layout).
    pub fn encode_rgba8(&self, data: Vec<u8>, width: u32, height: u32) -> Result<Vec<u8>, String> {
        let expected_len = (width as usize) * (height as usize) * 4;
        if data.len() != expected_len {
            return Err(format!(
                "encode_rgba8: expected {expected_len} bytes for {width}x{height} RGBA8, got {}",
                data.len()
            ));
        }
        let source = RgbaSliceU8::new(&data, (width as usize, height as usize));
        let yuv = YUVBuffer::from_rgba8_source(source);
        let mut encoder = self.inner.lock().map_err(|_| "H264Encoder: lock poisoned".to_string())?;
        let bitstream = encoder.encode(&yuv).map_err(|e| e.to_string())?;
        Ok(bitstream.to_vec())
    }
}

#[frb(opaque)]
pub struct H264Decoder {
    inner: Mutex<Decoder>,
}

impl H264Decoder {
    pub fn create() -> Result<H264Decoder, String> {
        let decoder = Decoder::new().map_err(|e| e.to_string())?;
        Ok(H264Decoder { inner: Mutex::new(decoder) })
    }

    /// Feeds one depacketized H264 access unit's worth of Annex-B bytes in.
    /// openh264 buffers internally across calls (SPS/PPS, reference frames) and
    /// only returns `Some` once it has produced a displayable picture - most
    /// calls (e.g. one that only delivered parameter sets) return `None`, which
    /// is not an error.
    pub fn decode(&self, data: Vec<u8>) -> Result<Option<DecodedVideoFrame>, String> {
        let mut decoder = self.inner.lock().map_err(|_| "H264Decoder: lock poisoned".to_string())?;
        let Some(yuv) = decoder.decode(&data).map_err(|e| e.to_string())? else {
            return Ok(None);
        };
        let (width, height) = yuv.dimensions();
        let mut rgb = vec![0u8; width * height * 3];
        yuv.write_rgb8(&mut rgb);
        Ok(Some(DecodedVideoFrame {
            width: width as u32,
            height: height as u32,
            rgb,
        }))
    }
}

// Unit tests, not `tests/*.rs` integration tests, because this crate only
// builds `cdylib`/`staticlib` (what cargokit needs) - no `rlib` - so an
// integration test has no way to link against the crate's own items.
//
// This validates the actual new, hand-written risk here - the openh264
// wrapper itself - independent of RTP/webrtc-rs (which
// `tests/webrtc_loopback.rs` already covers, and which the depacketizer glue
// in `api/media.rs` reuses verbatim from webrtc-rs's own H264 RTP code, not
// something newly written here).
#[cfg(test)]
mod tests {
    use super::*;

    const WIDTH: u32 = 64;
    const HEIGHT: u32 = 64;

    /// A solid-color BGRA8 frame - `width * height * 4` bytes, `[B, G, R, A]`
    /// per pixel repeated.
    fn solid_bgra_frame(width: u32, height: u32, b: u8, g: u8, r: u8) -> Vec<u8> {
        let mut data = Vec::with_capacity((width * height * 4) as usize);
        for _ in 0..(width * height) {
            data.extend_from_slice(&[b, g, r, 255]);
        }
        data
    }

    #[test]
    fn encode_decode_roundtrip_preserves_dimensions_and_roughly_the_color() {
        let encoder = H264Encoder::create(500_000).expect("create encoder");
        let decoder = H264Decoder::create().expect("create decoder");

        // Solid mid-gray-ish red frame - avoids pure 0/255 extremes, which
        // some YUV<->RGB rounding edge cases handle less representatively
        // than a mid-range value.
        let frame = solid_bgra_frame(WIDTH, HEIGHT, 40, 60, 180);

        let mut decoded = None;
        // A single encoded frame commonly needs to be fed to the decoder
        // more than once to get a picture out (e.g. if the encoder splits
        // SPS/PPS from the slice NAL, or the decoder needs a second call to
        // flush) - encode the same still frame a few times, matching how a
        // real video call would behave for an unchanging camera scene, and
        // stop at the first decoded picture.
        for _ in 0..5 {
            let encoded = encoder
                .encode_bgra8(frame.clone(), WIDTH, HEIGHT)
                .expect("encode_bgra8");
            assert!(!encoded.is_empty(), "encoder produced no bytes");
            // Annex-B start code check - every NAL openh264 emits should be
            // prefixed with 00 00 00 01 (or the encoder wrapper wouldn't be
            // usable by the RTP H264 payloader, which expects this).
            assert_eq!(
                &encoded[..4],
                &[0x00, 0x00, 0x00, 0x01],
                "encoded output is not Annex-B start-code prefixed"
            );

            if let Some(frame) = decoder.decode(encoded).expect("decode") {
                decoded = Some(frame);
                break;
            }
        }

        let decoded = decoded.expect("decoder never produced a picture across 5 encoded frames");
        assert_eq!(decoded.width, WIDTH);
        assert_eq!(decoded.height, HEIGHT);
        assert_eq!(decoded.rgb.len(), (WIDTH * HEIGHT * 3) as usize);

        // Average the decoded RGB and check it's in the right ballpark for
        // the BGR(40, 60, 180) input, i.e. R should clearly be the dominant
        // channel - loose bounds because of lossy encoding and
        // BGRA->YUV420->RGB rounding.
        let mut sum = [0u64; 3];
        for px in decoded.rgb.chunks_exact(3) {
            sum[0] += px[0] as u64;
            sum[1] += px[1] as u64;
            sum[2] += px[2] as u64;
        }
        let pixel_count = (WIDTH * HEIGHT) as u64;
        let avg = [sum[0] / pixel_count, sum[1] / pixel_count, sum[2] / pixel_count];
        assert!(
            avg[0] > avg[1] && avg[0] > avg[2],
            "expected red to dominate the decoded frame, got avg RGB = {avg:?}"
        );
        assert!(
            avg[0] > 100,
            "expected a clearly reddish frame (input R=180), got avg RGB = {avg:?}"
        );
    }
}
