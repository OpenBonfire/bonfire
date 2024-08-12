import 'package:flutter_webrtc/flutter_webrtc.dart';

class SdpBuilder {
  static String buildLocalOffer(RTCSessionDescription description) {
    const String header = '''
v=0\r
o=mozilla...THIS_IS_SDPARTA-99.0 6245156062326862977 2 IN IP4 0.0.0.0\r
s=-\r
t=0 0\r
''';

    return '';
  }

  static String _extractRelevantSdpInfo(RTCSessionDescription description) {
    final sdp = description.sdp!;
    final lines = sdp.split('\r\n');
    final relevantLines = lines
        .where((line) =>
            line.startsWith('m=audio') ||
            line.startsWith('a=fingerprint:') ||
            line.startsWith('c=IN IP4') ||
            line.startsWith('a=rtcp:') ||
            line.startsWith('a=ice-ufrag:') ||
            line.startsWith('a=ice-pwd:') ||
            line.startsWith('a=candidate:'))
        .toList();

    return relevantLines.join('\r\n');
  }

  static String _getDescriptionLineValue(String sdp, String prefix) {
    final lines = sdp.split('\r\n');
    final line = lines.firstWhere((line) => line.startsWith(prefix));

    return line.substring(prefix.length);
  }

  static String buildVoiceSelectSdp(RTCSessionDescription description) {
    return _extractRelevantSdpInfo(description);
  }

  static String buildRemoteSdp(String description) {
    String pwd = _getDescriptionLineValue(description, 'a=ice-pwd:');
    String ufrag = _getDescriptionLineValue(description, 'a=ice-ufrag:');
    String fingerprint =
        _getDescriptionLineValue(description, 'a=fingerprint:');
    String candidate = _getDescriptionLineValue(description, 'a=candidate:');
    String rtcp = _getDescriptionLineValue(description, 'a=rtcp:');
    String ip = _getDescriptionLineValue(description, 'c=IN IP4');

    return description;
  }
}
