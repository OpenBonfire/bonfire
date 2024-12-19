import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:firebridge/src/models/voice_gateway/event.dart';
import 'package:firebridge/src/voice_gateway/event_parser.dart';
import 'package:firebridge/src/voice_gateway/message.dart';

class VoiceConnection extends Stream<VoiceGatewayEvent>
    implements StreamSink<VoiceSend> {
  /// The connection to the Gateway.
  late WebSocketChannel channel;

  /// A stream on which [VoiceSent] events are added.
  Stream<VoiceSent> get onSent => _sentController.stream;
  final StreamController<VoiceSent> _sentController = StreamController();

  /// A stream of parsed events received from the Gateway.
  final Stream<VoiceGatewayEvent> events;

  VoiceConnection(this.channel, this.events);

  static Future<VoiceConnection> connect(String gatewayUri) async {
    final channel = WebSocketChannel.connect(Uri.parse(gatewayUri));

    // Wait for the connection to be established
    await channel.ready;

    final parser = VoiceEventParser();
    final eventStream = channel.stream.map((event) {
      return parser.parseVoiceGatewayEvent(
          jsonDecode(event as String) as Map<String, Object?>);
    });

    return VoiceConnection(channel, eventStream.asBroadcastStream());
  }

  @override
  Future<void> add(VoiceSend event) async {
    final payload = {
      'op': event.opcode.value,
      'd': event.data,
    };
    final encoded = jsonEncode(payload);
    channel.sink.add(encoded);
    _sentController.add(VoiceSent(payload: event));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      channel.sink.addError(error, stackTrace);

  @override
  Future<void> addStream(Stream<VoiceSend> stream) => stream.forEach(add);

  @override
  Future<void> close([int code = 1000]) async {
    await channel.sink.close(code);
    await _sentController.close();
  }

  @override
  Future<void> get done => channel.sink.done.then((_) => _sentController.done);

  @override
  StreamSubscription<VoiceGatewayEvent> listen(
    void Function(VoiceGatewayEvent event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return events.listen(onData,
        cancelOnError: cancelOnError, onDone: onDone, onError: onError);
  }
}
