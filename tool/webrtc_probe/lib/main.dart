import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dave/dave.dart' as dave;
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc_rs/flutter_webrtc_rs.dart';

import 'dave_voice_session.dart';
import 'probe_session.dart';
import 'voice_gateway.dart';

/// Standalone Discord voice/WebRTC/DAVE test harness - see this repo's
/// `tool/webrtc_probe/README.md`. Joins one voice channel, negotiates
/// WebRTC+DAVE exactly like the real app, sends synthetic audio/video (no
/// camera/mic hardware needed), runs for a fixed duration, then prints a
/// summary and exits. Driven entirely by `--dart-define` - never hardcode a
/// token in this file.
const _token = String.fromEnvironment('DISCORD_TOKEN');
const _guildId = String.fromEnvironment('GUILD_ID');
const _channelId = String.fromEnvironment('CHANNEL_ID');
const _testDuration = Duration(seconds: 60);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebridge.ensureInitialized();
  await RustLib.init();
  runApp(const _ProbeApp());
}

class _ProbeApp extends StatefulWidget {
  const _ProbeApp();

  @override
  State<_ProbeApp> createState() => _ProbeAppState();
}

class _ProbeAppState extends State<_ProbeApp> {
  final _log = <String>[];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_run()));
  }

  void _addLog(String line) {
    // Mirrored to stdout so `flutter run`'s own console output has it too -
    // that's what actually gets read back, the on-screen list is just for
    // watching live if the window happens to be visible.
    // ignore: avoid_print
    print(line);
    if (!mounted) return;
    setState(() => _log.add(line));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _run() async {
    if (_token.isEmpty || _guildId.isEmpty || _channelId.isEmpty) {
      _addLog(
        'ERROR: pass --dart-define=DISCORD_TOKEN=... --dart-define=GUILD_ID=... '
        '--dart-define=CHANNEL_ID=...',
      );
      exit(1);
    }

    _addLog('=== webrtc_probe starting ===');
    final guildId = Snowflake.parse(_guildId);
    final channelId = Snowflake.parse(_channelId);

    final client = await Firebridge.connectGatewayWithOptions(
      GatewayApiOptions(token: _token, compression: GatewayCompression.transport),
    );
    _addLog('logged in as ${client.user.id}');

    String? sessionId;
    String? voiceToken;
    String? endpoint;
    VoiceGateway? gateway;
    DaveVoiceSession? daveSession;
    ProbeVoiceSession? session;
    var connectedMedia = false;
    final done = Completer<void>();

    Future<void> maybeStartMedia() async {
      if (sessionId == null || voiceToken == null || endpoint == null || gateway != null) return;
      _addLog('have session_id + voice server info, connecting to voice gateway');

      gateway = VoiceGateway(
        endpoint: endpoint!,
        guildId: guildId,
        userId: client.user.id,
        sessionId: sessionId!,
        token: voiceToken!,
        maxDaveProtocolVersion: dave.daveMaxSupportedProtocolVersion(),
      );
      daveSession = DaveVoiceSession(gateway: gateway!, selfUserId: client.user.id, groupId: channelId);
      session = ProbeVoiceSession(
        gateway: gateway!,
        selfUserId: client.user.id,
        daveSession: daveSession!,
        log: _addLog,
      );

      gateway!.onClose.listen((close) {
        _addLog('voice gateway closed: code=${close.code} reason=${close.reason}');
      });

      gateway!.onSpeaking.listen((event) {
        session!.handleSpeaking(userId: Snowflake.parse(event.userId), ssrc: event.ssrc);
      });

      gateway!.onVideo.listen((update) {
        session!.handleVideoUpdate(update);
      });

      gateway!.onReady.listen((ready) async {
        _addLog('voice ready: ssrc=${ready.ssrc} streams=${ready.streams.length}');
        session!.localSsrc = ready.ssrc;
        final videoStream = ready.streams.where((s) => s.type == 'video').firstOrNull;
        final fragment = await session!.createOfferAndBuildFragment(videoStream: videoStream);
        gateway!.selectWebRtcProtocol(
          fragment,
          opusPayloadType: session!.opusPayloadType ?? 111,
          videoPayloadType: session!.videoPayloadType,
          videoRtxPayloadType: session!.videoRtxPayloadType,
        );
      });

      gateway!.onSessionDescription.listen((description) async {
        final sdp = description.sdp;
        if (sdp == null) {
          _addLog('ERROR: session description had no sdp (not in webrtc mode?)');
          return;
        }
        await session!.applyAnswer(sdp);
        final ssrc = session!.localSsrc;
        if (ssrc != null) gateway!.setSpeaking(ssrc: ssrc, speaking: true);
        connectedMedia = true;
        await session!.checkPayloadType();
        session!.startSyntheticAudio();
        await session!.startSyntheticVideo();

        // This, not the voice-gateway's opcode 12, is what actually drives
        // the "live" camera indicator other clients render - see
        // GatewayVoiceStateBuilder.selfVideo. Sent here, over the MAIN
        // gateway, once video has actually started.
        client.gateway.updateVoiceState(
          guildId,
          GatewayVoiceStateBuilder(channelId: channelId, muted: false, deafened: false, selfVideo: true),
        );
        _addLog('-> main gateway voice state update: self_video=true');
        _addLog('=== media pipeline fully started - running for ${_testDuration.inSeconds}s ===');
      });

      try {
        await gateway!.connect();
      } catch (error, stackTrace) {
        _addLog('ERROR connecting voice gateway: $error\n$stackTrace');
        if (!done.isCompleted) done.complete();
      }
    }

    client.onVoiceStateUpdate.listen((event) {
      if (event.userId != client.user.id) return;
      _addLog(
        '<- main gateway VOICE_STATE_UPDATE (self): channelId=${event.channelId} '
        'self_video=${event.videoEnabled} self_stream=${event.streaming}',
      );
      if (event.videoEnabled) session?.summary.selfVideoAcked = true;
      if (event.channelId == null) return;
      sessionId = event.sessionId;
      unawaited(maybeStartMedia());
    });
    client.onVoiceServerUpdate.listen((event) {
      if (event.guildId != guildId) return;
      voiceToken = event.token;
      endpoint = event.endpoint;
      unawaited(maybeStartMedia());
    });

    client.gateway.updateVoiceState(
      guildId,
      GatewayVoiceStateBuilder(channelId: channelId, muted: false, deafened: false),
    );

    Timer(_testDuration + const Duration(seconds: 10), () {
      if (!done.isCompleted) done.complete();
    });

    // Give the connection a head start before starting the countdown to the
    // actual test-duration cutoff, once media is confirmed connected.
    unawaited(() async {
      while (!connectedMedia && !done.isCompleted) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (done.isCompleted) return;
      await Future<void>.delayed(_testDuration);
      if (!done.isCompleted) done.complete();
    }());

    await done.future;

    _addLog('=== test duration elapsed, tearing down ===');
    if (session != null) {
      _addLog('FINAL SUMMARY: ${session!.summary}');
    } else {
      _addLog('FINAL SUMMARY: media pipeline never started');
    }

    client.gateway.updateVoiceState(
      guildId,
      GatewayVoiceStateBuilder(channelId: null, muted: false, deafened: false, selfVideo: false),
    );
    await session?.dispose();
    await daveSession?.dispose();
    await gateway?.close();
    await client.close();

    _addLog('=== done ===');
    await Future<void>.delayed(const Duration(seconds: 1));
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('webrtc_probe')),
        body: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: _log.length,
          itemBuilder: (context, index) => Text(_log[index], style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
        ),
      ),
    );
  }
}
