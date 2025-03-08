import 'dart:async';
import 'package:firebridge/src/api_options.dart';
import 'package:firebridge/src/builders/voice.dart';
import 'package:firebridge/src/builders/voice_gateway.dart';
import 'package:firebridge/src/client_options.dart';
import 'package:firebridge/src/http/handler.dart';
import 'package:firebridge/src/http/managers/voice_gateway_manager.dart';
import 'package:firebridge/src/models/voice_gateway/event.dart';
import 'package:firebridge/src/models/voice_gateway/opcode.dart';
import 'package:firebridge/src/models/voice_gateway/voice.dart';
import 'package:firebridge/src/voice_gateway/connection.dart';
import 'package:firebridge/src/voice_gateway/event_mixin.dart';
import 'package:firebridge/src/voice_gateway/event_parser.dart';
import 'package:firebridge/src/voice_gateway/message.dart';
import 'package:logging/logging.dart';

class VoiceGateway extends VoiceGatewayManager
    with VoiceEventParser, VoiceEventMixin {
  final VoiceGatewayUser voiceGatewayUser;
  final VoiceConnection connection;
  final Uri endpoint;
  late final Stream<VoiceGatewayEvent> events = connection.events;

  VoiceGateway(this.voiceGatewayUser, this.connection, this.endpoint)
      : super.create() {
    runHeartbeat();
    connection.events.listen((event) {
      if (event is VoiceHelloEvent) {
        connection.add(VoiceSend(opcode: VoiceOpcode.identify, data: {
          "server_id": voiceGatewayUser.serverId.value.toString(),
          "user_id": voiceGatewayUser.userId.value.toString(),
          "session_id": voiceGatewayUser.sessionId,
          "token": voiceGatewayUser.token,
          "video": true,
          "streams": [],
        }));
      }
      if (event is VoiceReadyEvent) {
        print("Voice Ready, attempting connect... ${event.ssrc}");
      }
      if (event is VoiceSessionDescriptionEvent) {
        print("Received Voice Session Description");
      }
    });
  }

  static Future<VoiceGateway> connect(
      VoiceGatewayUser voiceGatewayUser, Uri voiceConnectionUri) async {
    return VoiceGateway(
      voiceGatewayUser,
      await VoiceConnection.connect(voiceConnectionUri.toString()),
      voiceConnectionUri,
    );
  }

  Future<void> runHeartbeat() async {
    await for (final event in events) {
      if (event is VoiceHelloEvent) {
        final interval = Duration(milliseconds: event.heartbeatInterval);
        await for (final _ in Stream.periodic(interval)) {
          connection.add(VoiceSend(opcode: VoiceOpcode.heartbeat, data: null));
        }
      }
    }
  }

  Future<void> disconnect() async {
    await connection.close();
  }

  Future<void> sendVoiceIdentify(VoiceIdentifyBuilder builder) async {
    connection.add(VoiceSend(
      opcode: VoiceOpcode.identify,
      data: builder.build(),
    ));
  }

  Future<void> sendVoiceSelectProtocol(
      VoiceSelectProtocolBuilder builder) async {
    connection.add(VoiceSend(
      opcode: VoiceOpcode.selectProtocol,
      data: builder.build(),
    ));
  }

  // TODO: Make a proper builder and stuff
  Future<void> sendSpeaking(int ssrc) async {
    connection.add(VoiceSend(
      opcode: VoiceOpcode.speaking,
      data: {
        "speaking": 1 << 0,
        "delay": 0,
        "ssrc": ssrc,
      },
    ));
  }

  @override
  ApiOptions get apiOptions => throw UnimplementedError();

  @override
  Future<void> close() async {
    print("Closing voice gateway");
    await disconnect();
  }

  @override
  HttpHandler get httpHandler => throw UnimplementedError();

  @override
  Logger get logger => Logger("VoiceGateway");

  @override
  ClientOptions get options => throw UnimplementedError();
}
