import 'dart:async';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/voice/libs/sdp_builder.dart';
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

    _cancelSubscriptions();

    _voiceServerUpdateSubscription =
        user!.client.onVoiceServerUpdate.listen((event) {
      token = event.token;
      endpoint = event.endpoint;
      if (token != null && sessionId != null) {
        _connect(
          token: token!,
          guildId: guildId,
          sessionId: sessionId!,
          endpoint: endpoint!,
        );
      }
    });

    _voiceStateUpdateSubscription =
        user!.client.onVoiceStateUpdate.listen((event) {
      sessionId = event.state.sessionId;
      if (token != null && sessionId != null) {
        _connect(
          token: token!,
          guildId: guildId,
          sessionId: sessionId!,
          endpoint: endpoint!,
        );
      }
    });
  }

  Future<void> _initializeWebRTC(VoiceReadyEvent event) async {
    final configuration = <String, dynamic>{
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
    };

    // _peerConnection = await createPeerConnection(configuration);

    // no idea why we need 22 audio tracks, but discord does it
    // for (int i = 0; i < 12; i++) {
    //   MediaStream audioStream =
    //       await navigator.mediaDevices.getUserMedia({'audio': true});
    //   audioStream.getAudioTracks().forEach((track) {
    //     _peerConnection!.addTrack(track, audioStream);
    //   });
    // }

    // for (int i = 0; i < 12; i++) {
    //   MediaStream videoStream =
    //       await navigator.mediaDevices.getUserMedia({'video': false});
    //   videoStream.getVideoTracks().forEach((track) {
    //     _peerConnection!.addTrack(track, videoStream);
    //   });
    // }

    // _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
    //   // print("ICE candidate: ${candidate.toMap()}");
    //   // we can ignore ice candidates as we aren't "true" p2p
    // };

    // _peerConnection!.onIceConnectionState = (state) {
    //   // print("ICE connection state: $state");
    // };

    // _peerConnection!.onIceGatheringState = (state) {
    //   print("ICE gathering state: $state");
    // };

    // _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
    //   print('Connection state change: $state');
    // };

    // _peerConnection!.onSignalingState = (RTCSignalingState state) {
    //   print('Signaling state change: $state');
    // };

    // _peerConnection!.onAddStream = (MediaStream stream) {
    //   print('Stream added: $stream');
    // };

    // _localStream = await navigator.mediaDevices.getUserMedia({'audio': true});
    // _localStream!.getTracks().forEach((track) {
    //   _peerConnection!.addTrack(track, _localStream!);
    // });

    // _peerConnection!.onTrack = (event) {
    //   print("Received track: ${event.track}");
    //   event.track.enabled = true;
    // };

    // var offer = await _peerConnection!.createOffer(configuration);
    // // print("Created offer:\n${offer.sdp}");
    // // var mockOffer = await _peerConnection!.createOffer(configuration);
    // // print("LOCAL OFFER AS IT STANDS");
    // // print(mockOffer.sdp);
    // // var offer = RTCSessionDescription(
    // //   LocalBuilder.build(),
    // //   'offer',
    // // );

    // _peerConnection!.setLocalDescription(offer);
    // print("set wack offer");

    // _voiceClient!.sendVoiceSelectProtocol(
    //   VoiceSelectProtocolBuilder(
    //     protocol: "webrtc",
    //     data: SdpBuilder.buildVoiceSelectSdp(offer),
    //   ),
    // );
  }

  void _connect({
    required String token,
    required Snowflake guildId,
    required String sessionId,
    required String endpoint,
  }) async {
    if (_isConnecting) return;
    _isConnecting = true;

    _voiceClient = await Nyxx.connectVoiceGateway(
      VoiceGatewayUser(
        serverId: guildId,
        userId: user!.client.user.id,
        sessionId: sessionId,
        token: token,
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
      // print("GOT READY");
      state = event;

      await _initializeWebRTC(event);
    });
  }

  Future<void> _handleRemoteSdp(String remoteSdp) async {
    final lines = remoteSdp.split('\n');
    final modifiedLines = <String>[];

    String? fingerprint;
    String? iceUfrag;
    String? icePwd;
    String? rtcpLine;
    String? candidateLine;
    String? connectionLine;

    for (var line in lines) {
      if (line.contains('fingerprint:sha-256')) {
        fingerprint = line.startsWith('a=') ? line : 'a=$line';
      } else if (line.startsWith('a=ice-ufrag:')) {
        iceUfrag = line;
      } else if (line.startsWith('a=ice-pwd:')) {
        icePwd = line;
      } else if (line.startsWith('a=rtcp:')) {
        rtcpLine = line;
      } else if (line.startsWith('a=candidate:')) {
        candidateLine = line;
      } else if (line.startsWith('c=')) {
        connectionLine = line;
      }
    }

    if (fingerprint == null) {
      throw Exception("No fingerprint found in the original SDP");
    }

    modifiedLines.add('v=0');
    modifiedLines
        .add('o=- ${DateTime.now().millisecondsSinceEpoch} 2 IN IP4 127.0.0.1');
    modifiedLines.add('s=-');
    modifiedLines.add('t=0 0');

    modifiedLines
        .add('a=group:BUNDLE ${List.generate(12, (i) => i).join(' ')}');

    if (lines.contains('a=ice-lite')) {
      modifiedLines.add('a=ice-lite');
    }

    // add 12 audio tracks (I still have no idea why)
    for (int i = 0; i < 12; i++) {
      modifiedLines.add('m=audio 9 UDP/TLS/RTP/SAVPF 109 101');
      modifiedLines.add(connectionLine!);
      if (rtcpLine != null) modifiedLines.add(rtcpLine);
      modifiedLines.add('a=rtcp-mux');
      if (iceUfrag != null) modifiedLines.add(iceUfrag);
      modifiedLines.add(icePwd!);
      modifiedLines.add(fingerprint);
      modifiedLines.add('a=setup:active');
      modifiedLines.add('a=mid:$i');
      modifiedLines.add('a=sendrecv');
      modifiedLines.add('a=rtpmap:109 opus/48000/2');
      modifiedLines.add('a=rtpmap:101 telephone-event/8000');
      modifiedLines.add('a=fmtp:109 minptime=10;useinbandfec=1');
      if (candidateLine != null) modifiedLines.add(candidateLine);
    }

    final modifiedSdp = '${modifiedLines.join('\r\n')}\r\n';

    // print("Modified Remote SDP:");
    // print(modifiedSdp);

    // var modifiedSdp = RemoteBuilder.build();

    // final description = RTCSessionDescription(modifiedSdp, 'answer');
    // await _peerConnection!.setRemoteDescription(description);
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
