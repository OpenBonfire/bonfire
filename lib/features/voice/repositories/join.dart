// import 'dart:async';
// import 'package:bonfire/features/authentication/repositories/auth.dart';
// import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:firebridge/firebridge.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:sdp_transform/sdp_transform.dart';
// import 'package:universal_io/io.dart';

// part 'join.g.dart';

// @Riverpod()
// class VoiceChannelController extends _$VoiceChannelController {
//   AuthUser? user;
//   VoiceGateway? _voiceClient;
//   bool _isConnecting = false;
//   StreamSubscription? _voiceServerUpdateSubscription;
//   StreamSubscription? _voiceStateUpdateSubscription;
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   RTCSessionDescription? _currentLocalOffer;
//   int? ssrc;

//   @override
//   VoiceReadyEvent? build() {
//     var authUser = ref.watch(clientControllerProvider);
//     if (authUser is AuthUser) {
//       user = authUser;
//     }
//     return null;
//   }

//   void handleRemoteSdp(String sdp) async {
//     debugPrint("Handling remote SDP");
//     if (_peerConnection == null) return;

//     final parsedRemoteSdp = parse(sdp);
//     final remoteMedia = parsedRemoteSdp["media"][0];

//     final port = remoteMedia['port'];
//     final fingerprint0 = remoteMedia['fingerprint']["hash"];
//     final fingerprint = "sha-256 $fingerprint0";
//     final icePwd = remoteMedia['icePwd'];
//     final iceUfrag = remoteMedia['iceUfrag'];
//     final ip = remoteMedia['connection']['ip'];
//     final candidate0 = remoteMedia['candidates'][0];
//     final candidate =
//         "${candidate0['foundation']} ${candidate0['component']} ${candidate0['transport']} ${candidate0['priority']} ${candidate0['ip']} ${candidate0['port']} typ host";

//     final localDescription = _currentLocalOffer;
//     if (localDescription == null) return;

//     final localParsedSdp = parse(localDescription.sdp!);

//     final group = localParsedSdp['groups']?.firstWhere(
//       (group) => group['type'] == 'BUNDLE',
//       orElse: () => null,
//     );
//     if (group == null) throw Exception("BUNDLE group not found in local SDP");
//     debugPrint("Groups = $group");
//     final bundles = (group['mids'] as String).split(' ');

//     var remoteSdp = '''
// v=0
// o=- 1420070400000 0 IN IP4 127.0.0.1
// s=-
// t=0 0
// a=msid-semantic: WMS *
// a=group:BUNDLE ${bundles.join(' ')}
// ''';

//     for (var i = 0; i < localParsedSdp['media'].length; i++) {
//       final localMedia = localParsedSdp['media'][i];
//       final mediaType = localMedia['type'];

//       if (mediaType == 'audio') {
//         remoteSdp += '''
// m=audio $port UDP/TLS/RTP/SAVPF 111
// c=IN IP4 $ip
// a=rtpmap:111 opus/48000/2
// a=fmtp:111 minptime=10;useinbandfec=1;usedtx=1
// a=rtcp:$port
// a=rtcp-fb:111 transport-cc
// a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
// a=extmap:3 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
// a=setup:passive
// a=mid:${bundles[i]}
// a=recvonly
// a=ice-ufrag:$iceUfrag
// a=ice-pwd:$icePwd
// a=fingerprint:$fingerprint
// a=candidate:$candidate
// a=rtcp-mux
// ''';
//       } else if (mediaType == 'video') {
//         remoteSdp += '''
// m=video $port UDP/TLS/RTP/SAVPF 102 103
// c=IN IP4 $ip
// a=rtpmap:102 H264/90000
// a=rtpmap:103 rtx/90000
// a=fmtp:102 x-google-max-bitrate=2500;level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f
// a=fmtp:103 apt=102
// a=rtcp:$port
// a=rtcp-fb:102 ccm fir
// a=rtcp-fb:102 nack
// a=rtcp-fb:102 nack pli
// a=rtcp-fb:102 goog-remb
// a=rtcp-fb:102 transport-cc
// a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
// a=extmap:3 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
// a=extmap:14 urn:ietf:params:rtp-hdrext:toffset
// a=extmap:13 urn:3gpp:video-orientation
// a=extmap:5 http://www.webrtc.org/experiments/rtp-hdrext/playout-delay
// a=setup:passive
// a=mid:${bundles[i]}
// a=recvonly
// a=ice-ufrag:$iceUfrag
// a=ice-pwd:$icePwd
// a=fingerprint:$fingerprint
// a=candidate:$candidate
// a=rtcp-mux
// ''';
//       }
//     }

//     // debugPrint("Generated Remote SDP:\n$remoteSdp");
//     debugPrint("setting description");
//     final desc = RTCSessionDescription(remoteSdp, "answer");
//     await _peerConnection!.setRemoteDescription(desc);
//     debugPrint("should be set...");
//   }

//   Future<void> joinVoiceChannel(Snowflake guildId, Snowflake channelId) async {
//     if (user == null) return;

//     user!.client.updateVoiceState(
//       guildId,
//       GatewayVoiceStateBuilder(
//         channelId: channelId,
//         isMuted: false,
//         isDeafened: false,
//         isStreaming: false,
//       ),
//     );

//     String? token;
//     String? sessionId;
//     String? endpoint;

//     void connect() async {
//       if (_isConnecting) return;
//       _isConnecting = true;
//       debugPrint("Connecting to voice gateway...");
//       try {
//         _voiceClient = await Nyxx.connectVoiceGateway(
//           VoiceGatewayUser(
//             serverId: guildId,
//             userId: user!.client.user.id,
//             sessionId: sessionId!,
//             token: token!,
//             maxSecureFramesVersion: 0,
//             video: true,
//             streams: [],
//           ),
//           Uri.parse("wss://$endpoint"),
//         );

//         _voiceClient!.onVoiceSessionDescription.listen((event) {
//           debugPrint("Received Session Description");
//           handleRemoteSdp(event.sdp!);
//         });

//         _voiceClient!.onReady.listen((event) async {
//           debugPrint("Voice client is ready");
//           debugPrint(event.port.toString());
//           state = event;

//           await _initializeWebRTC(event);
//         });
//       } catch (e) {
//         debugPrint(
//             "Error connecting to voice gateway: ${(e as WebSocketException).message}");
//         state = null;
//       } finally {
//         _isConnecting = false;
//       }
//     }

//     _cancelSubscriptions();

//     _voiceServerUpdateSubscription =
//         user!.client.onVoiceServerUpdate.listen((event) {
//       token = event.token;
//       endpoint = event.endpoint;
//       if (token != null && sessionId != null) connect();
//     });

//     _voiceStateUpdateSubscription =
//         user!.client.onVoiceStateUpdate.listen((event) {
//       sessionId = event.state.sessionId;
//       if (token != null && sessionId != null) connect();
//     });
//   }

//   Future<void> _initializeWebRTC(VoiceReadyEvent event) async {
//     ssrc = event.ssrc;
//     _voiceClient!.sendSpeaking(ssrc!);
//     final configuration = <String, dynamic>{
//       'sdpSemantics': 'unified-plan',
//       'bundlePolicy': 'max-bundle',
//       'iceTransportPolicy': 'relay',
//     };

//     _peerConnection = await createPeerConnection(configuration);

//     _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
//       debugPrint("ICE candidate: ${candidate.toMap()}");
//     };

//     _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
//       debugPrint('Connection state change: $state');
//       if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {}
//     };

//     Future<void> handleNegotiation() async {
//       debugPrint("Handling...");
//       if (_peerConnection == null) return;

//       final offer = await _peerConnection!.createOffer({
//         'offerToReceiveAudio': true,
//         'offerToReceiveVideo': true,
//       });

//       debugPrint("Offering...");

//       // debugPrint("Local SDP = ${offer.sdp}");
//       _currentLocalOffer = offer;
//       await _peerConnection!.setLocalDescription(_currentLocalOffer!);

//       _voiceClient!.sendVoiceSelectProtocol(
//         VoiceSelectProtocolBuilder(
//           protocol: "webrtc",
//           data: offer.sdp!,
//         ),
//       );
//     }

//     _peerConnection!.onRenegotiationNeeded = () async {
//       debugPrint("Negotiation needed");
//       await handleNegotiation();
//     };

//     _peerConnection!.onSignalingState = (RTCSignalingState state) {
//       debugPrint('Signaling state change: $state');
//     };

//     _localStream = await navigator.mediaDevices
//         .getUserMedia({'audio': true, 'video': true});
//     _localStream!.getTracks().forEach((track) {
//       _peerConnection!.addTrack(track, _localStream!);
//     });

//     for (var i = 0; i < 10; i++) {
//       await _peerConnection!.addTransceiver(
//         kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
//         init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
//       );
//       _peerConnection!.addTransceiver(
//         kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
//         init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
//       );
//     }
//     debugPrint("Init called");
//     await handleNegotiation();
//   }

//   void leaveVoiceChannel() {
//     if (user == null) return;

//     user!.client.updateVoiceState(
//       Snowflake.zero,
//       GatewayVoiceStateBuilder(
//         channelId: null,
//         isMuted: false,
//         isDeafened: false,
//         isStreaming: false,
//       ),
//     );

//     _voiceClient?.close();
//     _voiceClient = null;

//     _peerConnection?.close();
//     _peerConnection = null;

//     _localStream?.dispose();
//     _localStream = null;

//     _cancelSubscriptions();
//     state = null;
//   }

//   void _cancelSubscriptions() {
//     _voiceServerUpdateSubscription?.cancel();
//     _voiceStateUpdateSubscription?.cancel();
//     _voiceServerUpdateSubscription = null;
//     _voiceStateUpdateSubscription = null;
//   }
// }
