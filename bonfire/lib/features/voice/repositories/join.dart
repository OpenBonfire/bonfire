import 'dart:async';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';

part 'join.g.dart';

@Riverpod()
class VoiceChannelController extends _$VoiceChannelController {
  AuthUser? user;
  VoiceGateway? _voiceClient;
  bool _isConnecting = false;
  StreamSubscription? _voiceServerUpdateSubscription;
  StreamSubscription? _voiceStateUpdateSubscription;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  String? _originalOfferSdp;
  List<String> _bundleMids = [];
  final Map<int, int> _ssrcMap = {};

  @override
  VoiceReadyEvent? build() {
    var authUser = ref.watch(authProvider.notifier).getAuth();
    if (authUser is AuthUser) {
      user = authUser;
    }
    return null;
  }

  Future<void> joinVoiceChannel(Snowflake guildId, Snowflake channelId) async {
    if (user == null) return;

    user!.client.updateVoiceState(
      guildId,
      GatewayVoiceStateBuilder(
        channelId: channelId,
        isMuted: false,
        isDeafened: false,
        isStreaming: false,
      ),
    );

    String? token;
    String? sessionId;
    String? endpoint;

    void connect() async {
      if (_isConnecting) return;
      _isConnecting = true;

      try {
        _voiceClient = await Nyxx.connectVoiceGateway(
          VoiceGatewayUser(
            serverId: guildId,
            userId: user!.client.user.id,
            sessionId: sessionId!,
            token: token!,
            maxSecureFramesVersion: 0,
            video: true,
            streams: [],
          ),
          Uri.parse("wss://$endpoint"),
        );

        _voiceClient!.onVoiceSessionDescription.listen((event) {
          _handleRemoteSdp(event.sdp!);
        });

        _voiceClient!.onReady.listen((event) async {
          state = event;
          await _initializeWebRTC(event);
        });
      } catch (e) {
        print("Error connecting to voice gateway: $e");
        state = null;
      } finally {
        _isConnecting = false;
      }
    }

    _cancelSubscriptions();

    _voiceServerUpdateSubscription =
        user!.client.onVoiceServerUpdate.listen((event) {
      token = event.token;
      endpoint = event.endpoint;
      if (token != null && sessionId != null) connect();
    });

    _voiceStateUpdateSubscription =
        user!.client.onVoiceStateUpdate.listen((event) {
      sessionId = event.state.sessionId;
      if (token != null && sessionId != null) connect();
    });
  }

  Future<void> _initializeWebRTC(VoiceReadyEvent event) async {
    final configuration = <String, dynamic>{
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'iceTransportPolicy': 'relay',
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      // Handle ICE candidates as needed
    };

    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true});
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    // Add transceivers to match JS example
    for (var i = 0; i < 10; i++) {
      _peerConnection!.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );
      _peerConnection!.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );
    }

    final offer = await _peerConnection!.createOffer();
    _originalOfferSdp = offer.sdp;
    final modifiedSdp = _patchLocalSdp(offer.sdp!);

    print("-- MODIFIED SDP --");

    await _peerConnection!
        .setLocalDescription(RTCSessionDescription(modifiedSdp, 'offer'));

    _voiceClient!.sendVoiceSelectProtocol(
      VoiceSelectProtocolBuilder(
        protocol: "webrtc",
        data: modifiedSdp,
      ),
    );
  }

  String _patchLocalSdp(String originalSdp) {
    final parsed = parse(originalSdp);
    _bundleMids =
        parsed['media']!.map<String>((m) => m['mid'].toString()).toList();

    parsed
      ..['msidSemantic'] = {'semantic': 'WMS', 'token': '*'}
      ..['groups'] = [
        {'type': 'BUNDLE', 'mids': _bundleMids.join(' ')}
      ]
      ..['iceOptions'] = 'trickle';

    parsed['media'] = parsed['media']!.map((media) {
      final isAudio = media['type'] == 'audio';
      final isPrimaryAudio = isAudio && media['mid'] == '0';

      return {
        ...media,
        'setup': 'actpass',
        'direction': isPrimaryAudio ? 'sendrecv' : 'recvonly',
        'extmap': _getExtMaps(isAudio, isPrimaryAudio),
        'rtp': _getCodecPayloads(isAudio),
        'fmtp': _getFmtpParams(isAudio),
        'rtcpFb': _getRtcpFeedback(isAudio),
      };
    }).toList();

    return write(parsed, {'format': 'planB'});
  }

  List<Map<String, dynamic>> _getExtMaps(bool isAudio, bool isPrimaryAudio) {
    if (isAudio) {
      return [
        {'value': 1, 'uri': 'urn:ietf:params:rtp-hdrext:ssrc-audio-level'},
        if (isPrimaryAudio)
          {
            'value': 2,
            'uri': 'urn:ietf:params:rtp-hdrext:csrc-audio-level',
            'direction': 'recvonly'
          },
        {'value': 3, 'uri': 'urn:ietf:params:rtp-hdrext:sdes:mid'},
      ];
    }
    return [
      {'value': 3, 'uri': 'urn:ietf:params:rtp-hdrext:sdes:mid'},
      {
        'value': 4,
        'uri': 'http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time'
      },
      {'value': 5, 'uri': 'urn:ietf:params:rtp-hdrext:toffset'},
      {
        'value': 6,
        'uri': 'http://www.webrtc.org/experiments/rtp-hdrext/playout-delay',
        'direction': 'recvonly'
      },
      {
        'value': 7,
        'uri':
            'http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01'
      },
    ];
  }

  List<Map<String, dynamic>> _getCodecPayloads(bool isAudio) {
    return isAudio
        ? [
            {'payload': 109, 'codec': 'opus', 'rate': 48000, 'encoding': 2},
            {'payload': 9, 'codec': 'G722', 'rate': 8000},
            {'payload': 0, 'codec': 'PCMU', 'rate': 8000},
            {'payload': 8, 'codec': 'PCMA', 'rate': 8000},
            {'payload': 101, 'codec': 'telephone-event', 'rate': 8000},
          ]
        : [
            {'payload': 126, 'codec': 'H264', 'rate': 90000},
            {'payload': 127, 'codec': 'rtx', 'rate': 90000},
          ];
  }

  List<Map<String, dynamic>> _getFmtpParams(bool isAudio) {
    return isAudio
        ? [
            {
              'payload': 109,
              'config': 'maxplaybackrate=48000;stereo=1;useinbandfec=1'
            },
            {'payload': 101, 'config': '0-15'},
          ]
        : [
            {
              'payload': 126,
              'config':
                  'profile-level-id=42e01f;level-asymmetry-allowed=1;packetization-mode=1'
            },
          ];
  }

  List<Map<String, dynamic>> _getRtcpFeedback(bool isAudio) {
    return isAudio
        ? []
        : [
            {'payload': 126, 'type': 'ccm', 'subtype': 'fir'},
            {'payload': 126, 'type': 'nack'},
            {'payload': 126, 'type': 'nack', 'subtype': 'pli'},
            {'payload': 126, 'type': 'goog-remb'},
            {'payload': 126, 'type': 'transport-cc'},
          ];
  }

  Future<void> _handleRemoteSdp(String remoteSdp) async {
    if (_peerConnection == null || _originalOfferSdp == null) return;

    final answer = _constructAnswerSdp(remoteSdp, _originalOfferSdp!);
    await _peerConnection!
        .setRemoteDescription(RTCSessionDescription(answer, 'answer'));
  }

  String _constructAnswerSdp(String remoteSdp, String originalOfferSdp) {
    final parsedRemote = parse(remoteSdp);
    final parsedOffer = parse(originalOfferSdp);
    final remoteMedia =
        List<Map<String, dynamic>>.from(parsedRemote['media'] ?? []);

    return write({
      'version': 0,
      'origin': parsedOffer['origin'],
      'name': '-',
      'timing': {'start': 0, 'stop': 0},
      'groups': parsedOffer['groups'],
      'msidSemantic': parsedOffer['msidSemantic'],
      'iceOptions': 'trickle',
      'fingerprint': parsedRemote['fingerprint'],
      'iceUfrag': parsedRemote['iceUfrag'],
      'icePwd': parsedRemote['icePwd'],
      'media': parsedOffer['media']!.map((originalMedia) {
        final mid = originalMedia['mid'];
        final remote = remoteMedia.firstWhere(
          (m) => m['mid'] == mid,
          orElse: () => {},
        );

        return {
          ...originalMedia,
          'iceUfrag': parsedRemote['iceUfrag'],
          'icePwd': parsedRemote['icePwd'],
          'setup': 'passive',
          'candidates': parsedRemote['candidates'],
          'port': remote['port'] ?? 0,
          'direction': remote['direction'] ?? 'inactive',
        };
      }).toList(),
    }, {
      'format': 'planB'
    });
  }

  void leaveVoiceChannel() {
    if (user == null) return;

    user!.client.updateVoiceState(
      Snowflake.zero,
      GatewayVoiceStateBuilder(
        channelId: null,
        isMuted: false,
        isDeafened: false,
        isStreaming: false,
      ),
    );

    _voiceClient?.close();
    _voiceClient = null;

    _peerConnection?.close();
    _peerConnection = null;

    _localStream?.dispose();
    _localStream = null;

    _cancelSubscriptions();
    state = null;
  }

  void _cancelSubscriptions() {
    _voiceServerUpdateSubscription?.cancel();
    _voiceStateUpdateSubscription?.cancel();
    _voiceServerUpdateSubscription = null;
    _voiceStateUpdateSubscription = null;
  }
}
