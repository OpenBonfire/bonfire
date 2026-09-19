import 'dart:async';

import 'package:flutter_webrtc_rs/flutter_webrtc_rs.dart';

/// Exercises the real API end to end, entirely in-process: two [RtcPeerConnection]s
/// exchange an offer/answer and (non-trickle - it just waits for ICE gathering to
/// finish on each side) ICE candidates directly in Dart, in place of a real signaling
/// server, then open a data channel and send a message each way.
///
/// This is the one thing the crate's Rust-level tests (`rust/tests/webrtc_loopback.rs`)
/// cannot cover: whether events actually cross the flutter_rust_bridge `StreamSink`
/// boundary correctly and opaque handles (`RtcPeerConnection`, `RtcDataChannel`) behave
/// as expected from Dart. Shared between the demo UI ([main.dart]) and
/// `integration_test/loopback_test.dart` so both run the exact same scenario.
Future<void> runLoopbackDemo(void Function(String) log) async {
  log('creating offerer + answerer peer connections…');
  // Bind loopback explicitly: some sandboxed/containerized networks don't hairpin a
  // process's own LAN-facing address back to itself, which would otherwise hang ICE
  // connectivity checks forever even though both peers are on the same machine.
  const loopbackConfig = RtcConfig(iceServers: [], udpBindAddrs: ['127.0.0.1:0']);
  final offerer = await RtcPeerConnection.create(config: loopbackConfig);
  final answerer = await RtcPeerConnection.create(config: loopbackConfig);

  final offererGathered = Completer<void>();
  final answererGathered = Completer<void>();
  final offererConnected = Completer<void>();
  final answererConnected = Completer<void>();
  String? remoteDataChannelId;
  final remoteDataChannelSeen = Completer<void>();

  offerer.events().listen((event) {
    log('[offerer] $event');
    switch (event) {
      case PeerConnectionEvent_IceGatheringStateChanged(:final field0):
        if (field0 == IceGatheringState.complete && !offererGathered.isCompleted) {
          offererGathered.complete();
        }
      case PeerConnectionEvent_ConnectionStateChanged(:final field0):
        if (field0 == PeerConnectionState.connected && !offererConnected.isCompleted) {
          offererConnected.complete();
        }
      default:
        break;
    }
  });

  answerer.events().listen((event) {
    log('[answerer] $event');
    switch (event) {
      case PeerConnectionEvent_IceGatheringStateChanged(:final field0):
        if (field0 == IceGatheringState.complete && !answererGathered.isCompleted) {
          answererGathered.complete();
        }
      case PeerConnectionEvent_ConnectionStateChanged(:final field0):
        if (field0 == PeerConnectionState.connected && !answererConnected.isCompleted) {
          answererConnected.complete();
        }
      case PeerConnectionEvent_DataChannel(:final channelId):
        remoteDataChannelId = channelId;
        if (!remoteDataChannelSeen.isCompleted) remoteDataChannelSeen.complete();
      default:
        break;
    }
  });

  log('creating data channel on offerer…');
  final localChannel = await offerer.createDataChannel(label: 'demo');

  log('offer/answer exchange (non-trickle - waiting for full ICE gathering)…');
  final offer = await offerer.createOffer();
  await offerer.setLocalDescription(descriptionJson: offer);
  await offererGathered.future.timeout(const Duration(seconds: 10));
  final offerWithCandidates = await offerer.localDescription();

  await answerer.setRemoteDescription(descriptionJson: offerWithCandidates!);
  final answer = await answerer.createAnswer();
  await answerer.setLocalDescription(descriptionJson: answer);
  await answererGathered.future.timeout(const Duration(seconds: 10));
  final answerWithCandidates = await answerer.localDescription();

  await offerer.setRemoteDescription(descriptionJson: answerWithCandidates!);

  log('waiting for both sides to connect…');
  await offererConnected.future.timeout(const Duration(seconds: 10));
  await answererConnected.future.timeout(const Duration(seconds: 10));

  await remoteDataChannelSeen.future.timeout(const Duration(seconds: 10));
  final remoteChannel = await answerer.takeRemoteDataChannel(channelId: remoteDataChannelId!);

  final localOpen = Completer<void>();
  final remoteOpen = Completer<void>();
  final remoteGotMessage = Completer<String>();
  final localGotMessage = Completer<String>();

  localChannel.events().listen((event) {
    switch (event) {
      case DataChannelEvent_Open():
        if (!localOpen.isCompleted) localOpen.complete();
      case DataChannelEvent_Message(:final data, :final isText):
        if (isText && !localGotMessage.isCompleted) {
          localGotMessage.complete(String.fromCharCodes(data));
        }
      default:
        break;
    }
  });
  remoteChannel.events().listen((event) {
    switch (event) {
      case DataChannelEvent_Open():
        if (!remoteOpen.isCompleted) remoteOpen.complete();
      case DataChannelEvent_Message(:final data, :final isText):
        if (isText && !remoteGotMessage.isCompleted) {
          remoteGotMessage.complete(String.fromCharCodes(data));
        }
      default:
        break;
    }
  });

  log('waiting for data channel to open…');
  await localOpen.future.timeout(const Duration(seconds: 10));
  await remoteOpen.future.timeout(const Duration(seconds: 10));

  log('sending "hello from offerer"…');
  await localChannel.sendText(text: 'hello from offerer');
  final received = await remoteGotMessage.future.timeout(const Duration(seconds: 10));
  log('answerer received: "$received"');
  if (received != 'hello from offerer') {
    throw StateError('answerer received unexpected message: "$received"');
  }

  log('sending "hello from answerer"…');
  await remoteChannel.sendText(text: 'hello from answerer');
  final receivedBack = await localGotMessage.future.timeout(const Duration(seconds: 10));
  log('offerer received: "$receivedBack"');
  if (receivedBack != 'hello from answerer') {
    throw StateError('offerer received unexpected message: "$receivedBack"');
  }

  await offerer.close();
  await answerer.close();
}
