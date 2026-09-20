//! Rewrites an H264 SPS to force `vui_parameters`/`bitstream_restriction`
//! with `max_num_reorder_frames = 0` present, ported from the
//! `Discord-RE/Discord-video-stream` project's `SPSVUIRewriter.ts` (which
//! itself cites WebRTC's own
//! `common_video/h264/sps_vui_rewriter.cc`) - a project that has this exact
//! capture-to-real-Discord-voice-server path working.
//!
//! Why this matters here: our own `VideoToolboxEncoder`/`h264_mp4toannexb`
//! pipeline (see `capture::macos::encode`) never sets this, and WebRTC's
//! receive-side frame reassembly (which runs *before* DAVE decrypts - DAVE
//! only ever sees whatever bitstream that reassembly hands it) uses this
//! flag's absence/value to decide whether frames might arrive out of
//! decode order. Getting it wrong doesn't corrupt any single NAL's bytes,
//! but it can make the reassembled access unit DAVE receives not the one
//! our encoder actually produced - which looks exactly like an AEAD
//! failure ("Failed to finalize decryption") on the far end, and matches
//! what was observed live: keyframes (the only NALs carrying an SPS)
//! consistently failed to decrypt while delta frames mostly succeeded.
//!
//! This is a straight port of the reference's bit reader/writer and RBSP
//! walk - see that file for the field-by-field H264 SPS syntax being
//! walked; comments here are kept minimal since the semantics are already
//! documented there and in the H.264 spec (Rec. ITU-T H.264, 7.3.2.1.1 /
//! Annex E.1.1).

/// Mirrors `AnnexBBitstreamReader` - reads MSB-first bits from Annex-B RBSP
/// bytes, transparently skipping `emulation_prevention_three_byte` (an 0x03
/// byte inserted after any `00 00` to keep `00 00 00`/`00 00 01`/`00 00 02`/
/// `00 00 03` from appearing inside NAL payload data, so they can't be
/// mistaken for a start code or reserved sequence).
struct BitReader<'a> {
    buffer: &'a [u8],
    byte_offset: usize,
    bit_offset: u32,
}

impl<'a> BitReader<'a> {
    fn new(buffer: &'a [u8]) -> Self {
        Self { buffer, byte_offset: 0, bit_offset: 0 }
    }

    fn read_bits(&mut self, mut count: u32) -> u32 {
        let mut result: u32 = 0;
        while count > 0 {
            if self.bit_offset == 0
                && self.byte_offset >= 2
                && self.buffer[self.byte_offset - 2] == 0
                && self.buffer[self.byte_offset - 1] == 0
                && self.buffer[self.byte_offset] == 3
            {
                self.byte_offset += 1;
            }
            if self.bit_offset == 0 && count >= 8 {
                result = (result << 8) | self.buffer[self.byte_offset] as u32;
                self.byte_offset += 1;
                count -= 8;
            } else {
                let num_bits_to_read = count.min(8 - self.bit_offset);
                let mask = (1u32 << num_bits_to_read) - 1;
                let shift = 8 - self.bit_offset - num_bits_to_read;
                let new_bits = (self.buffer[self.byte_offset] as u32 >> shift) & mask;
                result = (result << num_bits_to_read) | new_bits;
                count -= num_bits_to_read;
                self.bit_offset += num_bits_to_read;
                if self.bit_offset == 8 {
                    self.bit_offset = 0;
                    self.byte_offset += 1;
                }
            }
        }
        result
    }

    fn read_unsigned(&mut self, bits: u32) -> u32 {
        self.read_bits(bits)
    }

    fn read_unsigned_exp_golomb(&mut self) -> u32 {
        let mut leading0 = 0u32;
        while self.read_bits(1) == 0 {
            leading0 += 1;
        }
        (1u32 << leading0) + self.read_bits(leading0) - 1
    }

    fn read_signed_exp_golomb(&mut self) -> i32 {
        let unsigned = self.read_unsigned_exp_golomb();
        if unsigned % 2 == 0 { -((unsigned / 2) as i32) } else { ((unsigned + 1) / 2) as i32 }
    }
}

/// Mirrors `AnnexBBitstreamWriter` - the inverse of `BitReader`, inserting
/// `emulation_prevention_three_byte`s as needed.
struct BitWriter {
    buf: Vec<u8>,
    pending_byte: u32,
    bit_offset: u32,
}

impl BitWriter {
    fn new() -> Self {
        Self { buf: Vec::new(), pending_byte: 0, bit_offset: 0 }
    }

    /// Pushes `pending_byte` (inserting an emulation-prevention 0x03 first
    /// if needed) and resets it - called both internally whenever a byte
    /// fills up and once more, unconditionally, at the very end (matching
    /// the reference exactly, including its harmless quirk of sometimes
    /// pushing one extra trailing zero byte - always valid to have
    /// arbitrary zero bytes trailing `rbsp_trailing_bits()`).
    fn flush(&mut self) {
        let len = self.buf.len();
        if self.pending_byte <= 3 && len >= 2 && self.buf[len - 1] == 0 && self.buf[len - 2] == 0 {
            self.buf.push(3);
        }
        self.buf.push(self.pending_byte as u8);
        self.pending_byte = 0;
        self.bit_offset = 0;
    }

    fn write_bits(&mut self, bits: u32, mut count: u32) {
        while count > 0 {
            if self.bit_offset == 0 {
                if count >= 8 {
                    self.pending_byte = (bits >> (count - 8)) & 0xff;
                    count -= 8;
                    self.flush();
                } else {
                    let mask = (1u32 << count) - 1;
                    self.pending_byte |= (bits & mask) << (8 - count);
                    self.bit_offset = count;
                    count = 0;
                }
            } else {
                let num_bits_to_write = count.min(8 - self.bit_offset);
                let bits_to_write = (bits >> (count - num_bits_to_write)) & ((1u32 << num_bits_to_write) - 1);
                self.pending_byte |= bits_to_write << (8 - self.bit_offset - num_bits_to_write);
                count -= num_bits_to_write;
                self.bit_offset += num_bits_to_write;
                if self.bit_offset == 8 {
                    self.bit_offset = 0;
                    self.flush();
                }
            }
        }
    }

    fn write_unsigned(&mut self, num: u32, count: u32) {
        self.write_bits(num, count);
    }

    fn write_unsigned_exp_golomb(&mut self, num: u32) {
        let num = num + 1;
        let bit_count = 32 - num.leading_zeros();
        self.write_bits(0, bit_count - 1);
        self.write_bits(num, bit_count);
    }

    fn write_signed_exp_golomb(&mut self, num: i32) {
        if num <= 0 {
            self.write_unsigned_exp_golomb((-2i64 * num as i64) as u32);
        } else {
            self.write_unsigned_exp_golomb((2i64 * num as i64 - 1) as u32);
        }
    }
}

const HIGH_PROFILES: &[u32] = &[100, 110, 122, 244, 44, 83, 86, 118, 128, 138, 144];

fn add_bitstream_restriction(writer: &mut BitWriter, max_num_ref_frames: u32) {
    writer.write_bits(1, 1); // motion_vectors_over_pic_boundaries_flag (default 1)
    writer.write_unsigned_exp_golomb(2); // max_bytes_per_pic_denom (default 2)
    writer.write_unsigned_exp_golomb(1); // max_bits_per_mb_denom (default 1)
    writer.write_unsigned_exp_golomb(16); // log2_max_mv_length_horizontal (default 16)
    writer.write_unsigned_exp_golomb(16); // log2_max_mv_length_vertical (default 16)
    // max_num_reorder_frames - the whole point of this rewrite: our encoder
    // never reorders frames (no B-frames - see VideoToolboxEncoder's
    // `max_b_frames = 0`), so this must be 0, matching what WebRTC's
    // receive-side reassembly otherwise has to assume/enforce anyway.
    writer.write_unsigned_exp_golomb(0);
    writer.write_unsigned_exp_golomb(max_num_ref_frames); // max_dec_frame_buffering
}

fn read_write_hrd_parameters(reader: &mut BitReader, writer: &mut BitWriter) {
    let cpb_cnt_minus1 = reader.read_unsigned_exp_golomb();
    writer.write_unsigned_exp_golomb(cpb_cnt_minus1);
    let bit_rate_scale = reader.read_bits(4);
    writer.write_bits(bit_rate_scale, 4);
    let cpb_size_scale = reader.read_bits(4);
    writer.write_bits(cpb_size_scale, 4);
    for _ in 0..=cpb_cnt_minus1 {
        let bit_rate_value_minus1 = reader.read_unsigned_exp_golomb();
        writer.write_unsigned_exp_golomb(bit_rate_value_minus1);
        let cpb_size_value_minus1 = reader.read_unsigned_exp_golomb();
        writer.write_unsigned_exp_golomb(cpb_size_value_minus1);
        let cbr_flag = reader.read_bits(1);
        writer.write_bits(cbr_flag, 1);
    }
    writer.write_bits(reader.read_bits(5), 5); // initial_cpb_removal_delay_length_minus1
    writer.write_bits(reader.read_bits(5), 5); // cpb_removal_delay_length_minus1
    writer.write_bits(reader.read_bits(5), 5); // dpb_output_delay_length_minus1
    writer.write_bits(reader.read_bits(5), 5); // time_offset_length
}

/// `nal` is one SPS NAL unit's bytes (the 1-byte NAL header followed by its
/// RBSP), start-code and emulation-prevention-byte-laden exactly as it
/// appears in an Annex-B stream. Returns the rewritten NAL unit's bytes in
/// the same form. Panics on malformed/unexpected input (mirrors the
/// reference implementation's own `throw`s) - callers must not let that
/// panic escape past their own frame (see `rewrite_sps_in_annexb_frame`).
fn rewrite_sps_vui(nal: &[u8]) -> Vec<u8> {
    let mut reader = BitReader::new(&nal[1..]);
    let mut writer = BitWriter::new();

    writer.write_unsigned(nal[0] as u32, 8);

    let profile_idc = reader.read_unsigned(8);
    writer.write_unsigned(profile_idc, 8);
    writer.write_unsigned(reader.read_unsigned(8), 8); // constraint_flags
    writer.write_unsigned(reader.read_unsigned(8), 8); // level_idc
    writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // seq_parameter_set_id

    if HIGH_PROFILES.contains(&profile_idc) {
        let chroma_format_idc = reader.read_unsigned_exp_golomb();
        writer.write_unsigned_exp_golomb(chroma_format_idc);

        if chroma_format_idc == 3 {
            writer.write_bits(reader.read_bits(1), 1); // separate_colour_plane_flag
        }

        writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // bit_depth_luma_minus8
        writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // bit_depth_chroma_minus8
        writer.write_bits(reader.read_bits(1), 1); // qpprime_y_zero_transform_bypass_flag

        let seq_scaling_matrix_present_flag = reader.read_bits(1);
        writer.write_bits(seq_scaling_matrix_present_flag, 1);
        if seq_scaling_matrix_present_flag != 0 {
            let scaling_count = if chroma_format_idc != 3 { 8 } else { 12 };
            for i in 0..scaling_count {
                let seq_scaling_list_present_flag = reader.read_bits(1);
                writer.write_bits(seq_scaling_list_present_flag, 1);
                if seq_scaling_list_present_flag != 0 {
                    let size = if i < 6 { 16 } else { 64 };
                    let mut last_scale: i32 = 8;
                    for _ in 0..size {
                        let delta = reader.read_signed_exp_golomb();
                        writer.write_signed_exp_golomb(delta);
                        let next_scale = (last_scale + delta + 256).rem_euclid(256);
                        if next_scale != 0 {
                            last_scale = next_scale;
                        }
                    }
                }
            }
        }
    }

    writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // log2_max_frame_num_minus4

    let pic_order_cnt_type = reader.read_unsigned_exp_golomb();
    writer.write_unsigned_exp_golomb(pic_order_cnt_type);
    if pic_order_cnt_type == 0 {
        writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // log2_max_pic_order_cnt_lsb_minus4
    } else if pic_order_cnt_type == 1 {
        writer.write_bits(reader.read_bits(1), 1); // delta_pic_order_always_zero_flag
        writer.write_signed_exp_golomb(reader.read_signed_exp_golomb()); // offset_for_non_ref_pic
        writer.write_signed_exp_golomb(reader.read_signed_exp_golomb()); // offset_for_top_to_bottom_field
        let num_ref_frames_in_pic_order_cnt_cycle = reader.read_unsigned_exp_golomb();
        writer.write_unsigned_exp_golomb(num_ref_frames_in_pic_order_cnt_cycle);
        for _ in 0..num_ref_frames_in_pic_order_cnt_cycle {
            writer.write_signed_exp_golomb(reader.read_signed_exp_golomb()); // offset_for_ref_frame
        }
    }

    let max_num_ref_frames = reader.read_unsigned_exp_golomb();
    writer.write_unsigned_exp_golomb(max_num_ref_frames);

    writer.write_bits(reader.read_bits(1), 1); // gaps_in_frame_num_value_allowed_flag
    writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // pic_width_in_mbs_minus1
    writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // pic_height_in_map_units_minus1

    let frame_mbs_only_flag = reader.read_bits(1);
    writer.write_bits(frame_mbs_only_flag, 1);
    if frame_mbs_only_flag == 0 {
        writer.write_bits(reader.read_bits(1), 1); // mb_adaptive_frame_field_flag
    }

    writer.write_bits(reader.read_bits(1), 1); // direct_8x8_inference_flag

    let frame_cropping_flag = reader.read_bits(1);
    writer.write_bits(frame_cropping_flag, 1);
    if frame_cropping_flag != 0 {
        writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // frame_crop_left_offset
        writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // frame_crop_right_offset
        writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // frame_crop_top_offset
        writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // frame_crop_bottom_offset
    }

    let vui_parameters_present_flag = reader.read_bits(1);
    writer.write_bits(1, 1); // force vui_parameters_present_flag = 1

    if vui_parameters_present_flag == 0 {
        writer.write_bits(0, 2); // aspect_ratio_info_present_flag, overscan_info_present_flag
        writer.write_bits(0, 1); // video_signal_type_present_flag
        // chroma_loc_info_present_flag, timing_info_present_flag,
        // nal_hrd_parameters_present_flag, vcl_hrd_parameters_present_flag,
        // pic_struct_present_flag
        writer.write_bits(0, 5);
        writer.write_bits(1, 1); // bitstream_restriction_flag
        add_bitstream_restriction(&mut writer, max_num_ref_frames);
    } else {
        let aspect_ratio_info_present_flag = reader.read_bits(1);
        writer.write_bits(aspect_ratio_info_present_flag, 1);
        if aspect_ratio_info_present_flag != 0 {
            let aspect_ratio_idc = reader.read_unsigned(8);
            writer.write_unsigned(aspect_ratio_idc, 8);
            if aspect_ratio_idc == 255 {
                writer.write_unsigned(reader.read_unsigned(16), 16); // sar_width
                writer.write_unsigned(reader.read_unsigned(16), 16); // sar_height
            }
        }

        let overscan_info_present_flag = reader.read_bits(1);
        writer.write_bits(overscan_info_present_flag, 1);
        if overscan_info_present_flag != 0 {
            writer.write_bits(reader.read_bits(1), 1); // overscan_appropriate_flag
        }

        // Read the video signal type, but don't copy it (matches reference).
        let video_signal_type_present_flag = reader.read_bits(1);
        writer.write_bits(0, 1);
        if video_signal_type_present_flag != 0 {
            let _video_format = reader.read_bits(3);
            let _video_full_range_flag = reader.read_bits(1);
            let colour_description_present_flag = reader.read_bits(1);
            if colour_description_present_flag != 0 {
                let _colour_primaries = reader.read_unsigned(8);
                let _transfer_characteristics = reader.read_unsigned(8);
                let _matrix_coeffs = reader.read_unsigned(8);
            }
        }

        let chroma_loc_info_present_flag = reader.read_bits(1);
        writer.write_bits(chroma_loc_info_present_flag, 1);
        if chroma_loc_info_present_flag != 0 {
            writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // chroma_sample_loc_type_top_field
            writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // chroma_sample_loc_type_bottom_field
        }

        let timing_info_present_flag = reader.read_bits(1);
        writer.write_bits(timing_info_present_flag, 1);
        if timing_info_present_flag != 0 {
            writer.write_unsigned(reader.read_unsigned(32), 32); // num_units_in_tick
            writer.write_unsigned(reader.read_unsigned(32), 32); // time_scale
            writer.write_bits(reader.read_bits(1), 1); // fixed_frame_rate_flag
        }

        let nal_hrd_parameters_present_flag = reader.read_bits(1);
        writer.write_bits(nal_hrd_parameters_present_flag, 1);
        if nal_hrd_parameters_present_flag != 0 {
            read_write_hrd_parameters(&mut reader, &mut writer);
        }

        let vcl_hrd_parameters_present_flag = reader.read_bits(1);
        writer.write_bits(vcl_hrd_parameters_present_flag, 1);
        if vcl_hrd_parameters_present_flag != 0 {
            read_write_hrd_parameters(&mut reader, &mut writer);
        }

        if nal_hrd_parameters_present_flag != 0 || vcl_hrd_parameters_present_flag != 0 {
            writer.write_bits(reader.read_bits(1), 1); // low_delay_hrd_flag
        }

        writer.write_bits(reader.read_bits(1), 1); // pic_struct_present_flag

        let bitstream_restriction_flag = reader.read_bits(1);
        writer.write_bits(1, 1); // force bitstream_restriction_flag = 1
        if bitstream_restriction_flag == 0 {
            add_bitstream_restriction(&mut writer, max_num_ref_frames);
        } else {
            writer.write_bits(reader.read_bits(1), 1); // motion_vectors_over_pic_boundaries_flag
            writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // max_bytes_per_pic_denom
            writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // max_bits_per_mb_denom
            writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // log2_max_mv_length_horizontal
            writer.write_unsigned_exp_golomb(reader.read_unsigned_exp_golomb()); // log2_max_mv_length_vertical
            let _num_reorder_frames = reader.read_unsigned_exp_golomb();
            writer.write_unsigned_exp_golomb(0); // max_num_reorder_frames - forced to 0, see add_bitstream_restriction
            let _max_dec_frame_buffering = reader.read_unsigned_exp_golomb();
            writer.write_unsigned_exp_golomb(max_num_ref_frames); // max_dec_frame_buffering
        }
    }

    writer.write_bits(1, 1); // rbsp_stop_one_bit
    writer.flush();
    writer.buf
}

fn find_next_start_code(data: &[u8], from: usize) -> Option<(usize, usize)> {
    if data.len() < from + 3 {
        return None;
    }
    let mut i = from;
    while i + 2 < data.len() {
        if data[i] == 0 && data[i + 1] == 0 && data[i + 2] == 1 {
            if i >= 1 && data[i - 1] == 0 {
                return Some((i - 1, 4));
            }
            return Some((i, 3));
        }
        i += 1;
    }
    None
}

fn split_annexb_nalus(data: &[u8]) -> Vec<&[u8]> {
    let mut nalus = Vec::new();
    let Some((start_idx, code_len)) = find_next_start_code(data, 0) else {
        return nalus;
    };
    let mut nal_start = start_idx + code_len;
    loop {
        match find_next_start_code(data, nal_start) {
            Some((next_idx, next_len)) => {
                if next_idx > nal_start {
                    nalus.push(&data[nal_start..next_idx]);
                }
                nal_start = next_idx + next_len;
            }
            None => {
                if nal_start < data.len() {
                    nalus.push(&data[nal_start..]);
                }
                break;
            }
        }
    }
    nalus
}

/// Rewrites the SPS NAL (if any) in an Annex-B H264 frame - see this
/// module's doc for why. Every NAL is re-emitted with a 4-byte start code
/// (DAVE's own NAL parser normalizes to this anyway - see
/// `codec_utils.cpp`'s `ProcessFrameH264` - so this doesn't need to match
/// whatever `h264_mp4toannexb` used). Frames with no SPS (delta frames)
/// come back byte-identical modulo start-code length. A malformed SPS
/// (parse panic) is logged and passed through unrewritten rather than
/// dropping the frame or crashing the encode thread.
pub fn rewrite_sps_in_annexb_frame(data: &[u8]) -> Vec<u8> {
    let nalus = split_annexb_nalus(data);
    let mut out = Vec::with_capacity(data.len() + 16);
    for nalu in nalus {
        out.extend_from_slice(&[0, 0, 0, 1]);
        if !nalu.is_empty() && nalu[0] & 0x1F == 7 {
            match std::panic::catch_unwind(|| rewrite_sps_vui(nalu)) {
                Ok(rewritten) => out.extend_from_slice(&rewritten),
                Err(_) => {
                    log::warn!("capture_kit: SPS VUI rewrite failed on a malformed/unexpected SPS, sending it unrewritten");
                    out.extend_from_slice(nalu);
                }
            }
        } else {
            out.extend_from_slice(nalu);
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    fn nal_type(nal: &[u8]) -> u8 {
        nal[0] & 0x1F
    }

    /// Builds a minimal-but-valid baseline-profile SPS (no VUI at all) with
    /// the writer itself, rather than guessing at real encoder output bytes
    /// by hand - this way the "before" structure is known exactly, and the
    /// test is a genuine round trip through the same bit reader/writer the
    /// real rewrite uses, not a hand-computed byte dump that's one
    /// mis-copied nibble away from silently testing the wrong thing.
    fn synthetic_sps_without_vui() -> Vec<u8> {
        let mut w = BitWriter::new();
        w.write_unsigned(0x67, 8); // NAL header: type 7 (SPS)
        w.write_unsigned(66, 8); // profile_idc = 66 (Baseline, not a high profile)
        w.write_unsigned(0, 8); // constraint_flags
        w.write_unsigned(30, 8); // level_idc
        w.write_unsigned_exp_golomb(0); // seq_parameter_set_id
        w.write_unsigned_exp_golomb(2); // log2_max_frame_num_minus4
        w.write_unsigned_exp_golomb(0); // pic_order_cnt_type = 0
        w.write_unsigned_exp_golomb(2); // log2_max_pic_order_cnt_lsb_minus4
        w.write_unsigned_exp_golomb(4); // max_num_ref_frames
        w.write_bits(0, 1); // gaps_in_frame_num_value_allowed_flag
        w.write_unsigned_exp_golomb(19); // pic_width_in_mbs_minus1 (-> 320px)
        w.write_unsigned_exp_golomb(14); // pic_height_in_map_units_minus1 (-> 240px)
        w.write_bits(1, 1); // frame_mbs_only_flag
        w.write_bits(0, 1); // direct_8x8_inference_flag
        w.write_bits(0, 1); // frame_cropping_flag = 0
        w.write_bits(0, 1); // vui_parameters_present_flag = 0 (the case under test)
        w.write_bits(1, 1); // rbsp_stop_one_bit
        w.flush();
        w.buf
    }

    #[test]
    fn round_trips_a_typical_high_profile_sps_and_forces_no_reordering() {
        let sps = synthetic_sps_without_vui();
        assert_eq!(nal_type(&sps), 7);

        let rewritten = rewrite_sps_vui(&sps);
        assert_eq!(rewritten[0], sps[0]);

        // Re-parse just enough of the rewritten SPS to confirm
        // vui_parameters_present_flag and bitstream_restriction_flag both
        // ended up set, and max_num_reorder_frames == 0 - the actual
        // property this whole rewrite exists to guarantee.
        let mut reader = BitReader::new(&rewritten[1..]);
        let profile_idc = reader.read_unsigned(8);
        reader.read_unsigned(8); // constraint_flags
        reader.read_unsigned(8); // level_idc
        reader.read_unsigned_exp_golomb(); // seq_parameter_set_id
        if HIGH_PROFILES.contains(&profile_idc) {
            let chroma_format_idc = reader.read_unsigned_exp_golomb();
            if chroma_format_idc == 3 {
                reader.read_bits(1);
            }
            reader.read_unsigned_exp_golomb(); // bit_depth_luma_minus8
            reader.read_unsigned_exp_golomb(); // bit_depth_chroma_minus8
            reader.read_bits(1); // qpprime_y_zero_transform_bypass_flag
            assert_eq!(reader.read_bits(1), 0, "test SPS has no scaling matrix");
        }
        reader.read_unsigned_exp_golomb(); // log2_max_frame_num_minus4
        let pic_order_cnt_type = reader.read_unsigned_exp_golomb();
        assert_eq!(pic_order_cnt_type, 0, "test SPS uses poc type 0");
        reader.read_unsigned_exp_golomb(); // log2_max_pic_order_cnt_lsb_minus4
        let max_num_ref_frames = reader.read_unsigned_exp_golomb();
        reader.read_bits(1); // gaps_in_frame_num_value_allowed_flag
        reader.read_unsigned_exp_golomb(); // pic_width_in_mbs_minus1
        reader.read_unsigned_exp_golomb(); // pic_height_in_map_units_minus1
        let frame_mbs_only_flag = reader.read_bits(1);
        if frame_mbs_only_flag == 0 {
            reader.read_bits(1);
        }
        reader.read_bits(1); // direct_8x8_inference_flag
        let frame_cropping_flag = reader.read_bits(1);
        if frame_cropping_flag != 0 {
            reader.read_unsigned_exp_golomb();
            reader.read_unsigned_exp_golomb();
            reader.read_unsigned_exp_golomb();
            reader.read_unsigned_exp_golomb();
        }

        let vui_parameters_present_flag = reader.read_bits(1);
        assert_eq!(vui_parameters_present_flag, 1, "rewrite must force VUI present");
        // aspect_ratio_info_present_flag, overscan_info_present_flag
        assert_eq!(reader.read_bits(2), 0);
        // video_signal_type_present_flag
        assert_eq!(reader.read_bits(1), 0);
        // chroma_loc_info_present_flag, timing_info_present_flag,
        // nal_hrd_parameters_present_flag, vcl_hrd_parameters_present_flag,
        // pic_struct_present_flag
        assert_eq!(reader.read_bits(5), 0);
        let bitstream_restriction_flag = reader.read_bits(1);
        assert_eq!(bitstream_restriction_flag, 1, "rewrite must force bitstream_restriction present");
        reader.read_bits(1); // motion_vectors_over_pic_boundaries_flag
        reader.read_unsigned_exp_golomb(); // max_bytes_per_pic_denom
        reader.read_unsigned_exp_golomb(); // max_bits_per_mb_denom
        reader.read_unsigned_exp_golomb(); // log2_max_mv_length_horizontal
        reader.read_unsigned_exp_golomb(); // log2_max_mv_length_vertical
        let max_num_reorder_frames = reader.read_unsigned_exp_golomb();
        assert_eq!(max_num_reorder_frames, 0, "the whole point of this rewrite");
        let max_dec_frame_buffering = reader.read_unsigned_exp_golomb();
        assert_eq!(max_dec_frame_buffering, max_num_ref_frames);
    }

    #[test]
    fn leaves_delta_frames_with_no_sps_alone() {
        // start code + a plain slice NAL (type 1), no SPS anywhere.
        let frame: &[u8] = &[0, 0, 0, 1, 0x41, 0xaa, 0xbb, 0xcc];
        let rewritten = rewrite_sps_in_annexb_frame(frame);
        assert_eq!(&rewritten[4..], &frame[4..]);
    }

    #[test]
    fn rewrites_sps_within_a_full_keyframe_and_preserves_other_nalus() {
        let sps = synthetic_sps_without_vui();
        // Content doesn't matter for PPS/slice - rewrite_sps_in_annexb_frame
        // only ever parses NAL type 7 - these just need the right NAL
        // header type so the test can assert they passed through untouched.
        let pps: &[u8] = &[0x68, 0xeb, 0xe3, 0xcb, 0x22, 0xc0];
        let idr_slice: &[u8] = &[0x65, 0x88, 0x84, 0x00, 0x10];

        let mut frame = Vec::new();
        for nal in [sps.as_slice(), pps, idr_slice] {
            frame.extend_from_slice(&[0, 0, 0, 1]);
            frame.extend_from_slice(nal);
        }

        let rewritten = rewrite_sps_in_annexb_frame(&frame);
        let nalus = split_annexb_nalus(&rewritten);
        assert_eq!(nalus.len(), 3);
        assert_eq!(nal_type(nalus[0]), 7);
        assert_ne!(nalus[0], sps.as_slice(), "SPS must actually be rewritten, not passed through");
        assert_eq!(nalus[1], pps);
        assert_eq!(nalus[2], idr_slice);
    }
}
