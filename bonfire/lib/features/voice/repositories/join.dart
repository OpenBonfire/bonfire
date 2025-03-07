import 'dart:async';
import 'dart:convert';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:flutter/services.dart';
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

  @override
  VoiceReadyEvent? build() {
    var authUser = ref.watch(authProvider.notifier).getAuth();
    if (authUser is AuthUser) {
      user = authUser;
    }
    return null;
  }

  void handleRemoteSdp(String sdp) async {
    print("Handling remote SDP");
    print(sdp);
    if (_peerConnection == null) return;

    final desc = RTCSessionDescription(sdp, "answer");
    await _peerConnection!.setRemoteDescription(desc);
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
          handleRemoteSdp(event.sdp!);
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
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {}
    };

    Future<void> _handleNegotiation() async {
      print("Handling...");
      if (_peerConnection == null) return;

      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });

      print("Offering...");

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

    for (var i = 0; i < 10; i++) {
      await _peerConnection!.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );
      _peerConnection!.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );
    }

    // final parsedGeneratedOffer = parse(generatedOffer.sdp!);
    // final media = parsedGeneratedOffer["media"];
    // print(jsonEncode(parsedGeneratedOffer));
    // final fingerprint = parsedGeneratedOffer["media"][0]['fingerprint'];

    // final localDescriptionFile = await rootBundle.loadString(
    //   'assets/sdps/local-description.sdp',
    // );
    // final localOfferTemplate = parse(localDescriptionFile);
    // print("Patching fingerprint: $fingerprint");
    // localOfferTemplate['fingerprint'] = fingerprint;
    // localOfferTemplate['media'] = media;
    // final localOffer = write(localOfferTemplate, null);

    // final desc = RTCSessionDescription(generatedOffer.sdp!, "offer");
    // await _peerConnection!.setLocalDescription(desc);
    await _handleNegotiation();
    // print("Created offer:\n${offer.sdp}");
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
