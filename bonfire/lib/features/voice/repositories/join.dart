import 'dart:async';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebridge/firebridge.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';

part 'join.g.dart';

@Riverpod()
class VoiceChannelController extends _$VoiceChannelController {
  AuthUser? user;
  VoiceGateway? _voiceClient;
  bool _isConnecting = false;
  StreamSubscription? _voiceServerUpdateSubscription;
  StreamSubscription? _voiceStateUpdateSubscription;
  // RTCPeerConnection? _peerConnection;
  // MediaStream? _localStream;
  Map<String, dynamic>? _lastOfferConstraints;

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

        // _voiceClient!.onVoiceSessionDescription.listen((event) {
        //   print("Received Session Description");
        //   _handleRemoteSdp(event.sdp!);
        // });

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

    // _peerConnection = await createPeerConnection(configuration);

    // _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
    //   print("ICE candidate: ${candidate.toMap()}");
    //   // TODO: Implement sending ICE candidate to Discord
    // };

    // _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
    //   print('Connection state change: $state');
    //   if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
    //     print("Connection failed, closing peer connection");
    //     _peerConnection?.close();
    //     _peerConnection = null;
    //   }

    //   if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
    //     print("Connected to Discord!!!");
    //   }
    // };

    // _peerConnection!.onRenegotiationNeeded = () async {
    //   print("Negotiation needed");
    //   await _handleNegotiation();
    // };

    // _peerConnection!.onSignalingState = (RTCSignalingState state) {
    //   print('Signaling state change: $state');

    //   if (state == RTCSignalingState.RTCSignalingStateStable) {
    //     print("Signaling state is stable");
    //     _createAndSendOffer();
    //   }
    // };

    // _localStream = await navigator.mediaDevices
    //     .getUserMedia({'audio': true, 'video': true});
    // _localStream!.getTracks().forEach((track) {
    //   _peerConnection!.addTrack(track, _localStream!);
    // });

    // Initial negotiation
    // await _createAndSendOffer();
  }

  // Future<void> _handleNegotiation() async {
  //   if (_peerConnection == null) return;

  //   // Check signaling state before proceeding
  //   if (_peerConnection!.signalingState ==
  //       RTCSignalingState.RTCSignalingStateStable) {
  //     await _createAndSendOffer();
  //   } else {
  //     print("Cannot create offer, signaling state is not stable");
  //   }
  // }

  // Future<void> _createAndSendOffer() async {
  //   if (_peerConnection == null) return;

  //   // Use consistent constraints for all offers
  //   _lastOfferConstraints = {
  //     'offerToReceiveAudio': true,
  //     'offerToReceiveVideo': true,
  //   };

  //   RTCSessionDescription offer =
  //       await _peerConnection!.createOffer(_lastOfferConstraints!);
  //   String sdp = offer.sdp!;

  //   print("Created offer:");
  //   print(sdp);

  //   await _peerConnection!.setLocalDescription(offer);

  //   _voiceClient!.sendVoiceSelectProtocol(
  //     VoiceSelectProtocolBuilder(
  //       protocol: "webrtc",
  //       data: sdp,
  //     ),
  //   );
  // }

//   Future<void> _handleRemoteSdp(String remoteSdp) async {
//     if (_peerConnection == null) {
//       throw Exception("Peer connection not initialized");
//     }

//     print("Received SDP from Discord:");
//     print(remoteSdp);

//     // this is stupid
//     final lines = remoteSdp.split('\n');
//     String? fingerprint;
//     String? iceUfrag;
//     String? icePwd;
//     String? candidate;
//     String? ip;
//     String? port;

//     for (var line in lines) {
//       if (line.startsWith('a=fingerprint:')) {
//         fingerprint = line.split(' ')[1];
//       } else if (line.startsWith('a=ice-ufrag:')) {
//         iceUfrag = line.split(':')[1];
//       } else if (line.startsWith('a=ice-pwd:')) {
//         icePwd = line.split(':')[1];
//       } else if (line.startsWith('a=candidate:')) {
//         candidate = line.substring(2);
//         var parts = candidate.split(' ');
//         ip = parts[4];
//         port = parts[5];
//       } else if (line.startsWith('c=IN IP4')) {
//         ip = line.split(' ')[2];
//       } else if (line.startsWith('m=audio')) {
//         port = line.split(' ')[1];
//       }
//     }

//     // this is less stupid, but still stupid
//     String sdpAnswer = """
// v=0
// o=- ${DateTime.now().millisecondsSinceEpoch} 2 IN IP4 127.0.0.1
// s=-
// t=0 0
// m=audio $port UDP/TLS/RTP/SAVP 111
// c=IN IP4 $ip
// a=rtcp:$port IN IP4 $ip
// a=ice-ufrag:$iceUfrag
// a=ice-pwd:$icePwd
// a=fingerprint:sha-256 $fingerprint
// a=setup:active
// a=mid:0
// a=sendrecv
// a=rtcp-mux
// a=rtpmap:111 opus/48000/2
// a=fmtp:111 minptime=10;useinbandfec=1
// a=candidate:$candidate
// a=end-of-candidates
// """;

//     try {
//       await _peerConnection!.setRemoteDescription(
//         RTCSessionDescription(sdpAnswer, 'answer'),
//       );
//       print("Remote description set successfully");
//     } catch (e) {
//       print("Error setting remote description: $e");
//       print("Attempted SDP answer:");
//       print(sdpAnswer);
//     }
//   }

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

    // _peerConnection?.close();
    // _peerConnection = null;

    // _localStream?.dispose();
    // _localStream = null;

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
