import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:eterl/eterl.dart';
import 'package:firebridge/src/api_options.dart';
import 'package:firebridge/src/errors.dart';
import 'package:firebridge/src/gateway/event_parser.dart';
import 'package:firebridge/src/gateway/message.dart';
import 'package:firebridge/src/models/gateway/event.dart';
import 'package:firebridge/src/models/gateway/opcode.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:universal_io/io.dart';

/// An internal class that contains the logic for running a shard.
///
/// This class handles opening the connection, heartbeating and any connection lifecycle events.
class ShardRunner {
  /// The data needed for the shard to operate.
  final ShardData data;

  /// The current heartbeat timer.
  Timer? heartbeatTimer;

  /// The last seq number received.
  int? seq;

  /// The session ID from the latest READY event.
  String? sessionId;

  /// The current active connection.
  ShardConnection? connection;

  // Add messages to this controller for them to be sent back to the main isolate.
  final StreamController<ShardMessage> controller = StreamController();

  /// Whether the last heartbeat was ACKed.
  bool lastHeartbeatAcked = true;

  /// The stopwatch timing the interval between a heartbeat being sent and a heartbeat ACK being received.
  Stopwatch? heartbeatStopwatch;

  /// The interval between two heartbeats.
  Duration? heartbeatInterval;

  /// Whether the current connection can be resumed.
  bool canResume = false;

  /// Whether the shard is currently disposing and should not reconnect.
  bool disposing = false;

  /// The URI to use when connecting to the Gateway.
  late Uri gatewayUri = originalGatewayUri;

  /// The original URI to use when connecting to the Gateway for the first time or after an invalid session.
  late final Uri originalGatewayUri =
      data.originalConnectionUri.replace(queryParameters: {
    ...data.originalConnectionUri.queryParameters,
    ...data.apiOptions.gatewayConnectionOptions,
  });

  ShardRunner(this.data);

  /// Run the shard runner.
  Stream<ShardMessage> run(Stream<GatewayMessage> messages) async* {
    // sendHandler is responsible for handling requests for this shard to send messages to the Gateway.
    // It is paused whenever this shard isn't ready to send messages.
    final sendController = StreamController<Send>();
    final sendHandler = sendController.stream.listen((e) async {
      try {
        await connection!.add(e);
      } catch (error, s) {
        controller.add(ErrorReceived(error: error, stackTrace: s));

        // Prevent the recursive call to add() from looping too often.
        await Future.delayed(Duration(milliseconds: 100));
        // Try to send the event again, unless we are disposing (in which case the controller will be closed).
        if (!sendController.isClosed) {
          sendController.add(e);
        }
      }
    })
      ..pause();

    // identifyController serves as a notification system for Identify messages.
    // Any Identify messages received are added to this stream.
    final identifyController = StreamController<Identify>.broadcast();

    // startCompleter is completed when the Gateway instance is ready for this shard to start.
    final startCompleter = Completer<StartShard>();

    final messageHandler = messages.listen((message) {
      if (message is Send) {
        sendController.add(message);
      } else if (message is Identify) {
        identifyController.add(message);
      } else if (message is Dispose) {
        disposing = true;
        connection?.close();

        // We might get a dispose request while we are waiting to identify.
        // Add an error to the identify stream so we break out of the wait.
        identifyController.addError(
          Exception('Out of remaining session starts'),
          StackTrace.current,
        );

        // We need to start the shard to jump ahead to the check for exiting the shard.
        if (!startCompleter.isCompleted) {
          startCompleter.complete(StartShard());
        }
      } else if (message is StartShard) {
        if (startCompleter.isCompleted) {
          controller.add(ErrorReceived(
            error: StateError(
                'Received StartShard when shard was already started'),
            stackTrace: StackTrace.current,
          ));
          return;
        }

        startCompleter.complete(message);
      }
    });

    /// The main connection loop.
    ///
    /// Maintains an active connection until a dispose request is received or the websocket closes with an invalid code.
    Future<void> asyncRun() async {
      while (true) {
        try {
          // Check for dispose requests. If we should be disposing, exit the loop.
          // Do this now instead of after the connection is closed in case we get
          // a dispose request before the shard is even started.
          if (disposing) {
            controller.add(Disconnecting(reason: 'Dispose requested'));
            return;
          }

          // Initialize lastHeartbeatAcked to `true` so we don't immediately disconnect in heartbeat().
          lastHeartbeatAcked = true;

          // Open the websocket connection.
          connection =
              await ShardConnection.connect(gatewayUri.toString(), this);
          connection!.onSent.listen(controller.add);

          // Obtain the heartbeat interval from the HELLO event and start heartbeating.
          final hello = await connection!.first;
          if (hello is! HelloEvent) {
            throw InvalidEventException('Expected HELLO on connection.');
          }
          controller.add(EventReceived(event: hello));

          heartbeatInterval = hello.heartbeatInterval;
          startHeartbeat();

          // If we can resume (the connection loop was restarted) and we have the information needed, try to resume.
          // Otherwise, identify.
          if (canResume && seq != null && sessionId != null) {
            await sendResume();
          } else {
            // Request to identify and wait for the confirmation.
            controller.add(RequestingIdentify());
            await identifyController.stream.first;

            await sendIdentify();
          }

          canResume = true;

          // Handle events from the connection & forward them to the result controller.
          final subscription = connection!.listen((event) async {
            if (event is RawDispatchEvent) {
              seq = event.seq;

              if (event.name == 'READY') {
                final resumeUri =
                    Uri.parse(event.payload['resume_gateway_url'] as String);

                gatewayUri = resumeUri.replace(queryParameters: {
                  ...resumeUri.queryParameters,
                  ...data.apiOptions.gatewayConnectionOptions,
                });

                sessionId = event.payload['session_id'] as String;

                // We are connected, start handling send requests.
                sendHandler.resume();
              } else if (event.name == 'RESUMED') {
                sendHandler.resume();
              }
            } else if (event is ReconnectEvent) {
              controller.add(Reconnecting(reason: 'Reconnect requested'));
              connection!.close(4000);
            } else if (event is InvalidSessionEvent) {
              if (!event.isResumable) {
                canResume = false;
                gatewayUri = originalGatewayUri;
              }

              controller.add(Reconnecting(reason: 'Session invalidated'));
              connection!.close(4000);
            } else if (event is HeartbeatAckEvent) {
              lastHeartbeatAcked = true;
              heartbeatStopwatch = null;
            } else if (event is HeartbeatEvent) {
              try {
                await connection!
                    .add(Send(opcode: Opcode.heartbeat, data: seq));
              } on StateError {
                // ignore: Connection closed while adding event.
              }
            }

            controller.add(EventReceived(event: event));
          });

          // Wait for the current connection to end, either due to a remote close or due to us disconnecting.
          await subscription.asFuture();

          // Check if we can resume based on close code if the connection was closed by Discord.
          if (connection!.localCloseCode == null) {
            final remoteCloseCode = connection!.remoteCloseCode;

            if (remoteCloseCode == 1005 || remoteCloseCode == 1006) {
              controller
                  .add(Reconnecting(reason: 'Gateway connection was closed'));
            } else {
              // https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes
              const newSessionCodes = [4007, 4009];
              const errorCodes = [4004, 4010, 4011, 4012, 4013, 4014];

              if (errorCodes.contains(remoteCloseCode)) {
                controller.add(Disconnecting(
                    reason: 'Received error close code: $remoteCloseCode'));
                return;
              }

              canResume = !newSessionCodes.contains(remoteCloseCode);

              controller.add(Reconnecting(
                  reason: 'Connection was closed with code $remoteCloseCode'));
            }
          }
        } catch (error, stackTrace) {
          controller.add(ErrorReceived(error: error, stackTrace: stackTrace));
          // Prevents the while-true loop from looping too often when no internet is available.
          await Future.delayed(Duration(milliseconds: 100));

          controller.add(Reconnecting(reason: 'Error on Gateway connection'));
        } finally {
          // Pause the send subscription until we are connected again.
          // The handler may already be paused if the error occurred before we had identified.
          if (!sendHandler.isPaused) {
            sendHandler.pause();
          }

          // Reset connection properties.
          await connection?.close(4000);
          connection = null;
          heartbeatTimer?.cancel();
          heartbeatTimer = null;
          heartbeatStopwatch = null;
          heartbeatInterval = null;
        }
      }
    }

    await startCompleter.future;
    asyncRun().then((_) {
      controller.close();
      sendController.close();
      identifyController.close();
      messageHandler.cancel();
    });

    yield* controller.stream;
  }

  void heartbeat() {
    if (!lastHeartbeatAcked) {
      controller.add(Reconnecting(reason: 'Missed heartbeat'));
      connection!.close(4000);
      return;
    }

    connection!.add(Send(opcode: Opcode.heartbeat, data: seq));
    lastHeartbeatAcked = false;
  }

  void startHeartbeat() {
    heartbeatTimer = Timer(heartbeatInterval! * Random().nextDouble(), () {
      heartbeat();

      heartbeatTimer = Timer.periodic(heartbeatInterval!, (_) => heartbeat());
    });
  }

  Future<void> sendIdentify() async {
    await connection!.add(Send(
      opcode: Opcode.identify,
      data: {
        'token': data.apiOptions.token,
        'properties': {
          'os': 'Linux',
          'browser': 'Firefox',
          'device': '',
          "release_channel": "stable",
        },
        if (data.apiOptions.compression == GatewayCompression.payload)
          'compress': true,
        if (data.apiOptions.largeThreshold != null)
          'large_threshold': data.apiOptions.largeThreshold,
        'shard': [data.id, data.totalShards],
        if (data.apiOptions.initialPresence != null)
          'presence': data.apiOptions.initialPresence!.build(),
        'client_state': {
          'guild_versions': {},
        }
      },
    ));
  }

  Future<void> sendResume() async {
    assert(sessionId != null && seq != null);
    await connection!.add(Send(
      opcode: Opcode.resume,
      data: {
        'token': data.apiOptions.token,
        'session_id': sessionId,
        'seq': seq,
      },
    ));
  }
}

/// Handles parsing/encoding & compression/decompression of events on a WebSocketChannel connection to the Gateway.
class ShardConnection extends Stream<GatewayEvent> implements StreamSink<Send> {
  /// The number of messages that can be sent per [rateLimitDuration].
  // https://discord.com/developers/docs/topics/gateway#rate-limiting
  static const rateLimitCount = 120;

  /// The duration after which the rate limit resets.
  static const rateLimitDuration = Duration(seconds: 60);

  /// The connection to the Gateway.
  final WebSocketChannel channel;

  /// A stream of parsed events received from the Gateway.
  final Stream<GatewayEvent> events;

  /// The [ShardRunner] that created this connection.
  final ShardRunner runner;

  /// The code used to close this connection, or `null` if this connection is open or was closed by the remote server.
  int? localCloseCode;

  /// The code used to close this connection by the remote server, or `null` if this connection is open or was closed by calling [close].
  int? _remoteCloseCode;
  int? get remoteCloseCode => localCloseCode == null ? _remoteCloseCode : null;

  /// A stream on which [Sent] events are added.
  Stream<Sent> get onSent => _sentController.stream;
  final StreamController<Sent> _sentController = StreamController();

  /// The predicted number of heartbeats per [rateLimitDuration].
  ///
  /// The [rateLimitCount] is reduced by this value for any non heartbeat event so heartbeats can always be sent immediately.
  int get rateLimitHeartbeatReservation => (rateLimitDuration.inMicroseconds /
          runner.heartbeatInterval!.inMicroseconds)
      .ceil();

  /// The number of events sent in the current [rateLimitDuration].
  int _currentRateLimitCount = 0;

  /// A completer that completes once the current [rateLimitDuration] has passed.
  Completer<void> _currentRateLimitEnd = Completer<void>();

  /// Handles resetting [_currentRateLimitCount] and [_currentRateLimitEnd].
  late final Timer _rateLimitResetTimer;

  /// A completer that is completed when the connection is closed.
  final Completer<void> _closeCompleter = Completer<void>();

  ShardConnection(this.channel, this.events, this.runner) {
    _rateLimitResetTimer = Timer.periodic(rateLimitDuration, (timer) {
      _currentRateLimitCount = 0;
      _currentRateLimitEnd.complete();
      _currentRateLimitEnd = Completer<void>();
    });

    channel.sink.done.then((_) {
      _rateLimitResetTimer.cancel();

      // Attempt to extract the close code from the WebSocketChannel
      final webSocketCloseCode = channel.closeCode;
      if (webSocketCloseCode != null) {
        _remoteCloseCode = webSocketCloseCode;
      }

      if (!_currentRateLimitEnd.isCompleted) {
        _currentRateLimitEnd
          // Don't report an uncaught async error for the future.
          ..future.ignore()
          ..completeError(
              StateError('Connection is closed'), StackTrace.current);
      }
      _sentController.close();
      if (!_closeCompleter.isCompleted) {
        _closeCompleter.complete();
      }
    });
  }

  static Future<ShardConnection> connect(
      String gatewayUri, ShardRunner runner) async {
    final channel = WebSocketChannel.connect(Uri.parse(gatewayUri));
    // Wait for the connection to be established
    await channel.ready;

    Stream<dynamic> uncompressedStream;
    switch (runner.data.apiOptions.compression) {
      case GatewayCompression.transport:
        uncompressedStream =
            decompressTransport(channel.stream.cast<List<int>>());
        break;
      case GatewayCompression.payload:
        uncompressedStream = decompressPayloads(channel.stream);
        break;
      case GatewayCompression.none:
        uncompressedStream = channel.stream;
        break;
    }

    Stream<dynamic> dataStream;
    switch (runner.data.apiOptions.payloadFormat) {
      case GatewayPayloadFormat.json:
        dataStream = parseJson(uncompressedStream);
        break;
      case GatewayPayloadFormat.etf:
        dataStream = parseEtf(uncompressedStream.cast<List<int>>());
        break;
    }

    final parser = EventParser();
    final eventStream = dataStream.cast<Map<String, Object?>>().map((event) =>
        parser.parseGatewayEvent(event,
            heartbeatLatency: runner.heartbeatStopwatch?.elapsed));

    return ShardConnection(channel, eventStream.asBroadcastStream(), runner);
  }

  @override
  StreamSubscription<GatewayEvent> listen(
    void Function(GatewayEvent event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return events.listen(onData,
        cancelOnError: cancelOnError, onDone: onDone, onError: onError);
  }

  @override
  Future<void> add(Send event) async {
    final payload = {
      'op': event.opcode.value,
      'd': event.data,
    };

    final encoded = switch (runner.data.apiOptions.payloadFormat) {
      GatewayPayloadFormat.json => jsonEncode(payload),
      GatewayPayloadFormat.etf => eterl.pack(payload),
    };

    final rateLimitLimit =
        event.opcode == Opcode.heartbeat ? 0 : rateLimitHeartbeatReservation;
    while (rateLimitCount - _currentRateLimitCount <= rateLimitLimit) {
      try {
        await _currentRateLimitEnd.future;
      } catch (e) {
        // Swap out stack trace so the error message makes more sense.
        Error.throwWithStackTrace(e, StackTrace.current);
      }
    }

    if (event.opcode == Opcode.heartbeat) {
      runner.heartbeatStopwatch = Stopwatch()..start();
    }

    _currentRateLimitCount++;
    channel.sink.add(encoded);
    _sentController.add(Sent(payload: event));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      channel.sink.addError(error, stackTrace);

  @override
  Future<void> addStream(Stream<Send> stream) => stream.forEach(add);

  @override
  Future<void> close([int code = 1000]) async {
    localCloseCode ??= code;

    // We could map the reason but this works fine for now
    await channel.sink.close(code, '');

    return done;
  }

  @override
  Future<void> get done => _closeCompleter.future;
}

Stream<dynamic> decompressTransport(Stream<List<int>> raw) {
  final filter = RawZLibFilter.inflateFilter();

  return raw.map((chunk) {
    filter.process(chunk, 0, chunk.length);

    final buffer = <int>[];
    for (List<int>? decoded = [];
        decoded != null;
        decoded = filter.processed()) {
      buffer.addAll(decoded);
    }

    return buffer;
  });
}

Stream<dynamic> decompressPayloads(Stream<dynamic> raw) => raw.map((message) {
      if (message is String) {
        return message;
      } else {
        return zlib.decode(message as List<int>);
      }
    });

Stream<dynamic> parseJson(Stream<dynamic> raw) => raw.map((message) {
      final source =
          message is String ? message : utf8.decode(message as List<int>);

      return jsonDecode(source);
    });

Stream<dynamic> parseEtf(Stream<List<int>> raw) =>
    raw.transform(eterl.unpacker());

// This is a placeholder for the zlib class, which would need to be implemented or imported
class zlib {
  static List<int> decode(List<int> data) {
    // Implementation needed
    return [];
  }
}

// Constants needed for WebSocket status codes that were provided by dart:io WebSocket
class WebSocketStatus {
  static const int noStatusReceived = 1005;
  static const int abnormalClosure = 1006;
}
