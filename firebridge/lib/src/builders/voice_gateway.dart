import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/models/voice_gateway/event.dart';

class VoiceSelectProtocolBuilder
    extends CreateBuilder<VoiceSelectProtocolEvent> {
  /// The voice protocol to use (udp or webrtc)
  final String protocol;

  ///	The voice connection data or WebRTC SDP
  final String data;

  /// The UUID4 RTC connection ID, used for analytics
  final String? rtcConnectionId;

  ///	The supported audio/video codecs
  final List<Map<String, Object?>>? codecs;

  /// The received voice experiments to enable
  final List<String>? experiments;

  VoiceSelectProtocolBuilder({
    required this.protocol,
    required this.data,
    this.rtcConnectionId,
    this.codecs,
    this.experiments,
  });

  @override
  Map<String, Object?> build() => {
        'protocol': protocol,
        'data': data,
        // it's duplicated in the network tab, unsure as to why
        'sdp': data,
        if (rtcConnectionId != null) 'rtc_connection_id': rtcConnectionId,
        if (codecs != null) 'codecs': codecs,
        if (experiments != null) 'experiments': experiments,
      };
}
