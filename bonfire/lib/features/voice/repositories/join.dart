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
  List<Map<String, dynamic>>? _originalMediaSections;

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
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
      'iceTransportPolicy': 'relay',
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      print("ICE candidate: ${candidate.toMap()}");
      // TODO: Implement sending ICE candidate to Discord
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {}
    };

    Future<void> _handleNegotiation() async {
      if (_peerConnection == null) return;

      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      print("setting local description");
      print(offer.sdp);
      await _peerConnection!.setLocalDescription(offer);

      _voiceClient!.sendVoiceSelectProtocol(
        VoiceSelectProtocolBuilder(
          protocol: "webrtc",
          data: offer.sdp!,
        ),
      );
    }

    _peerConnection!.onRenegotiationNeeded = () async {
      print("Negotiation needed");
      await _handleNegotiation();
    };

    _peerConnection!.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    _localStream = await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': true});
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    final offer = await _peerConnection!.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    });

    // Store original media sections from offer
    final parsedOffer = parse(offer.sdp!);
    _originalMediaSections =
        List<Map<String, dynamic>>.from(parsedOffer['media']);

    await _peerConnection!.setLocalDescription(offer);
    print("Created offer:\n${offer.sdp}");

    _voiceClient!.sendVoiceSelectProtocol(
      VoiceSelectProtocolBuilder(
        protocol: "webrtc",
        data: offer.sdp!,
      ),
    );
  }

  Future<void> _handleRemoteSdp(String remoteSdp) async {
    if (_peerConnection == null || _originalMediaSections == null) return;

    final parsedRemote = parse(remoteSdp);
    final remoteMedia = parsedRemote['media'] ?? [];

    // Build the full answer SDP using original media structure
    final answerSdp = {
      'version': 0,
      'origin': {
        'username': '-',
        'sessionId': DateTime.now().millisecondsSinceEpoch,
        'sessionVersion': 2,
        'netType': 'IN',
        'ipVer': 4,
        'address': '127.0.0.1'
      },
      'name': '-',
      'timing': {'start': 0, 'stop': 0},
      'media': _originalMediaSections!.map((originalMedia) {
        final mediaType = originalMedia['type'];
        final mid = originalMedia['mid']?.toString() ?? '0';

        // Find matching remote media by MID (if available)
        final remote = remoteMedia.firstWhere(
          (m) => m['mid']?.toString() == mid,
          orElse: () => {},
        );

        // Common attributes for all media lines
        final baseMedia = {
          ...originalMedia,
          'iceUfrag': parsedRemote['iceUfrag'],
          'icePwd': parsedRemote['icePwd'],
          'fingerprint': parsedRemote['fingerprint'],
          'setup': 'passive',
          'candidates': parsedRemote['candidates'],
        };

        if (mediaType == 'audio') {
          return {
            ...baseMedia,
            'port': remote['port'] ?? parsedRemote['connection']?['ip'] ?? 0,
            'protocol': 'UDP/TLS/RTP/SAVPF',
            'connection':
                parsedRemote['connection'] ?? {'ip': '0.0.0.0', 'version': 4},
            'rtcp': {
              'port': remote['port'] ?? parsedRemote['connection']?['ip'] ?? 0
            },
            'direction': 'recvonly',
            'rtp': originalMedia['rtp'],
            'fmtp': originalMedia['fmtp'],
            'extmap': originalMedia['extmap'],
          };
        }

        // Video handling (mark inactive but preserve structure)
        return {
          ...baseMedia,
          'port': 0,
          'protocol': 'UDP/TLS/RTP/SAVPF',
          'direction': 'inactive',
          'connection': {'ip': '0.0.0.0', 'version': 4},
          'rtcp': {'port': 0},
        };
      }).toList()
    };

    // Generate the SDP string
    final sdpAnswer = write(answerSdp, {'format': 'planB'});

    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdpAnswer, 'answer'),
      );
      print("Successfully set remote description");
    } catch (e) {
      print("Error setting remote description: $e");
      print("Constructed SDP Answer:\n$sdpAnswer");
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
    _originalMediaSections = null;
    state = null;
  }

  void _cancelSubscriptions() {
    _voiceServerUpdateSubscription?.cancel();
    _voiceStateUpdateSubscription?.cancel();
    _voiceServerUpdateSubscription = null;
    _voiceStateUpdateSubscription = null;
  }
}
