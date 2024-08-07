import 'dart:async';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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
          print("Received Session Description");
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
      // 'iceServers': [],
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      // print("ICE candidate: ${candidate.toMap()}");
      // we can ignore ice candidates as we aren't "true" p2p
    };

    _peerConnection!.onIceConnectionState = (state) {
      print("ICE connection state: $state");
    };

    _peerConnection!.onIceGatheringState = (state) {
      print("ICE gathering state: $state");
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    _peerConnection!.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      print('Stream added: $stream');
    };

    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true});
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _peerConnection!.onTrack = (event) {
      print("Received remote track: ${event.track}");
    };

    RTCSessionDescription offer = await _peerConnection!.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    });

    String modifiedSdp = _modifySdp(offer.sdp!);

    // Set the local description with the original offer
    await _peerConnection!.setLocalDescription(offer);

    // Extract relevant SDP info from the modified SDP
    final relevantSdpInfo =
        _extractRelevantSdpInfo(RTCSessionDescription(modifiedSdp, 'offer'));

    _voiceClient!.sendVoiceSelectProtocol(
      VoiceSelectProtocolBuilder(
        protocol: "webrtc",
        data: relevantSdpInfo,
      ),
    );
  }

  String _modifySdp(String sdp) {
    final lines = sdp.split('\r\n');
    final modifiedLines = lines
        .map((line) {
          if (line.startsWith('m=audio')) {
            return line.replaceFirst(
                RegExp(r'UDP/TLS/RTP/SAVPF'), 'UDP/TLS/RTP/SAVP');
          } else if (line.startsWith('a=rtpmap:') && line.contains('opus')) {
            return 'a=rtpmap:109 opus/48000/2';
          } else if (line.startsWith('a=fmtp:') && line.contains('opus')) {
            return 'a=fmtp:109 minptime=10;useinbandfec=1;usedtx=1';
          } else if (line.startsWith('a=rtpmap:') && line.contains('VP8')) {
            return 'a=rtpmap:120 VP8/90000';
          } else if (line.startsWith('a=rtpmap:') && line.contains('rtx')) {
            return 'a=rtpmap:124 rtx/90000';
          } else if (line.startsWith('a=fmtp:') && line.contains('120')) {
            return 'a=fmtp:120 x-google-max-bitrate=2500';
          } else if (line.startsWith('a=fmtp:') && line.contains('124')) {
            return 'a=fmtp:124 apt=120';
          } else if (line.startsWith('a=extmap:')) {
            // Keep only the extmaps that Discord uses
            if (line.contains('urn:ietf:params:rtp-hdrext:ssrc-audio-level') ||
                line.contains(
                    'http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time') ||
                line.contains('urn:ietf:params:rtp-hdrext:toffset') ||
                line.contains(
                    'http://www.webrtc.org/experiments/rtp-hdrext/playout-delay') ||
                line.contains(
                    'http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01')) {
              return line;
            } else {
              return '';
            }
          }
          return line;
        })
        .where((line) => line.isNotEmpty)
        .toList();

    return modifiedLines.join('\r\n');
  }

  String _extractRelevantSdpInfo(RTCSessionDescription description) {
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

  Future<void> _handleRemoteSdp(String remoteSdp) async {
    if (_peerConnection == null) {
      throw Exception("Peer connection not initialized");
    }

    // print("Received SDP from Discord:");
    // print(remoteSdp);

    final lines = remoteSdp.split('\n');
    String? fingerprint;
    String? iceUfrag;
    String? icePwd;
    String? candidate;
    String? ip;
    String? port;

    for (var line in lines) {
      if (line.startsWith('a=fingerprint:')) {
        fingerprint = line.split(' ')[1];
      } else if (line.startsWith('a=ice-ufrag:')) {
        iceUfrag = line.split(':')[1];
      } else if (line.startsWith('a=ice-pwd:')) {
        icePwd = line.split(':')[1];
      } else if (line.startsWith('a=candidate:')) {
        candidate = line.substring(2);
        var parts = candidate.split(' ');
        ip = parts[4];
        port = parts[5];
      } else if (line.startsWith('c=IN IP4')) {
        ip = line.split(' ')[2];
      } else if (line.startsWith('m=audio')) {
        port = line.split(' ')[1];
      }
    }

    String sdpAnswer = """
v=0
o=- ${DateTime.now().millisecondsSinceEpoch} 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0
a=msid-semantic: WMS
m=audio $port UDP/TLS/RTP/SAVPF 111
c=IN IP4 $ip
a=rtcp:$port IN IP4 $ip
a=ice-ufrag:$iceUfrag
a=ice-pwd:$icePwd
a=ice-options:trickle
a=fingerprint:sha-256 $fingerprint
a=setup:active
a=mid:0
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=sendrecv
a=rtcp-mux
a=rtpmap:111 opus/48000/2
a=fmtp:111 minptime=10;useinbandfec=1
a=ssrc:1001 cname:discord-${DateTime.now().millisecondsSinceEpoch}
a=candidate:$candidate
a=end-of-candidates
""";

    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdpAnswer, 'answer'),
      );
      print("Remote description set successfully");
    } catch (e) {
      print("Error setting remote description: $e");
      print("Attempted SDP answer:");
      print(sdpAnswer);
    }
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
