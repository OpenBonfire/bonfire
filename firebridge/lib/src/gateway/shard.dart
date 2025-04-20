import 'dart:async';

import 'package:combine/combine.dart';
import 'package:firebridge/src/builders/guild/channel_statuses.dart';
import 'package:firebridge/src/builders/guild/guild_subscriptions_bulk.dart';
import 'package:logging/logging.dart';
import 'package:firebridge/src/api_options.dart';
import 'package:firebridge/src/builders/voice.dart';
import 'package:firebridge/src/client.dart';
import 'package:firebridge/src/gateway/message.dart';
import 'package:firebridge/src/gateway/shard_runner.dart';
import 'package:firebridge/src/models/gateway/event.dart';
import 'package:firebridge/src/models/gateway/opcode.dart';
import 'package:firebridge/src/models/snowflake.dart';

/// {@template shard}
/// A single connection to Discord's Gateway.
/// {@endtemplate}
class Shard extends Stream<ShardMessage> implements StreamSink<GatewayMessage> {
  /// The ID of this shard.
  final int id;

  /// The CombineInfo for this shard's runner.
  final CombineInfo combineInfo;

  /// The client this [Shard] is for.
  final NyxxGateway client;

  /// The logger used by this shard.
  Logger get logger => Logger('${client.options.loggerName}.Shards[$id]');

  final StreamController<ShardMessage> _rawReceiveController =
      StreamController();
  final StreamController<ShardMessage> _transformedReceiveController =
      StreamController.broadcast();

  final StreamController<GatewayMessage> _sendController = StreamController();

  final Completer<void> _doneCompleter = Completer();

  Duration _latency = Duration.zero;

  /// The latency on this shard's connection.
  ///
  /// This is updated for each [HeartbeatAckEvent] received. If no [HeartbeatAckEvent] has been received, this will be [Duration.zero].
  Duration get latency => _latency;

  /// Create a new [Shard].
  Shard(this.id, this.combineInfo, this.client) {
    client.initialized.then((_) {
      final sendStream = client.options.plugins.fold(
        _sendController.stream,
        (previousValue, plugin) =>
            plugin.interceptGatewayMessages(this, previousValue),
      );
      sendStream.listen((event) => combineInfo.messenger.send(event),
          cancelOnError: false, onDone: close);

      final transformedReceiveStream = client.options.plugins.fold(
        _rawReceiveController.stream,
        (previousValue, plugin) =>
            plugin.interceptShardMessages(this, previousValue),
      );
      transformedReceiveStream.pipe(_transformedReceiveController);
    });

    // Listen to messages from the Combine worker
    combineInfo.messenger.messages.listen((message) {
      if (message is ShardMessage) {
        _rawReceiveController.add(message);
      }
    });

    final subscription = listen((message) {
      if (message is Sent) {
        logger
          ..fine('Sent payload: ${message.payload.opcode.name}')
          ..finer(
              'Opcode: ${message.payload.opcode.value}, Data: ${message.payload.data}');
      } else if (message is ErrorReceived) {
        logger.warning(
            'Error: ${message.error}', message.error, message.stackTrace);
      } else if (message is Disconnecting) {
        logger.info('Disconnecting: ${message.reason}');
      } else if (message is Reconnecting) {
        logger.info('Reconnecting: ${message.reason}');
      } else if (message is EventReceived) {
        final event = message.event;

        if (event is! RawDispatchEvent) {
          logger.finer('Receive: ${event.opcode.name}');

          switch (event) {
            case InvalidSessionEvent(:final isResumable):
              if (isResumable) {
                logger.finest('Resumable: $isResumable');
              } else {
                logger.warning('Resumable: $isResumable');
              }
            case HelloEvent(:final heartbeatInterval):
              logger.finest('Heartbeat Interval: $heartbeatInterval');
            case HeartbeatAckEvent(:final latency):
              _latency = latency;
            default:
              break;
          }
        } else {
          logger
            ..fine('Receive event: ${event.name}')
            ..finer('Seq: ${event.seq}, Data: ${event.payload}');

          if (event.name == 'READY') {
            logger.info('Connected to Gateway');
          } else if (event.name == 'RESUMED') {
            logger.info('Reconnected to Gateway');
          }
        }
      } else if (message is RequestingIdentify) {
        logger.fine('Ready to identify');
      }
    });

    subscription.asFuture().then((value) {
      // Can happen if the shard closes unexpectedly.
      // Prevents further calls to close() from attempting to add events.
      if (!_doneCompleter.isCompleted) {
        _doneCompleter.complete(value);
      }
    });
  }

  /// Connect to the Gateway using the provided parameters.
  static Future<Shard> connect(
      int id,
      int totalShards,
      GatewayApiOptions apiOptions,
      Uri connectionUri,
      NyxxGateway client) async {
    final logger = Logger('${client.options.loggerName}.Shards[$id]');

    logger.fine('Spawning shard runner');

    // Define the data structure for the worker
    final shardData = _CombineShardData(
      totalShards: totalShards,
      id: id,
      apiOptions: apiOptions,
      originalConnectionUri: connectionUri,
    );

    // Create the Combine worker
    final combineInfo = await Combine().spawn(
      (context) async {
        final data = context.argument as _CombineShardData;
        final messenger = context.messenger;

        // Create the shard runner and handle communication
        final runner = ShardRunner(data);

        // Create a controller for incoming messages from the main thread
        final incomingController = StreamController<GatewayMessage>();

        // Listen for messages from the main thread
        messenger.messages.listen((message) {
          if (message is GatewayMessage) {
            incomingController.add(message);
          }
        });

        // Process messages from the runner and send them back to the main thread
        runner.run(incomingController.stream).listen(
          (message) {
            try {
              messenger.send(message);
            } catch (e, st) {
              messenger
                  .send(ErrorReceived(error: e.toString(), stackTrace: st));
            }
          },
          onDone: () => incomingController.close(),
        );
      },
      argument: shardData,
      debugName: "Shard #$id runner",
    );

    logger.fine('Shard runner ready');

    return Shard(id, combineInfo, client);
  }

  /// Update the client's voice state on this shard.
  void updateVoiceState(Snowflake guildId, GatewayVoiceStateBuilder builder) {
    add(Send(opcode: Opcode.voiceStateUpdate, data: {
      'guild_id': guildId.toString(),
      ...builder.build(),
    }));
  }

  /// Send a voice identify payload to the Gateway.
  void sendVoiceIdentify(VoiceIdentifyBuilder builder) {
    var data = builder.build();
    add(Send(opcode: Opcode.dispatch, data: data));
  }

  void updateChannelStatusesGuild(
      Snowflake guildId, ChannelStatusesBuilder builder) {
    add(Send(opcode: Opcode.guildSubscriptionsBulk, data: {
      'guild_id': guildId.toString(),
      ...builder.build(),
    }));
  }

  void updateGuildSubscriptionsBulk(
      Snowflake guildId, GuildSubscriptionsBulkBuilder builder) {
    add(Send(opcode: Opcode.guildSubscriptionsBulk, data: {
      ...builder.build(),
    }));
  }

  @override
  void add(GatewayMessage event) {
    if (event is Send) {
      logger
        ..fine('Sending: ${event.opcode.name}')
        ..finer('Opcode: ${event.opcode.value}, Data: ${event.data}');
    } else if (event is Dispose) {
      logger.info('Disposing');
    } else if (event is Identify) {
      logger.info('Connecting to Gateway');
    }

    _sendController.add(event);
  }

  @override
  StreamSubscription<ShardMessage> listen(
    void Function(ShardMessage event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _transformedReceiveController.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Future<void> close() {
    if (_doneCompleter.isCompleted) {
      return _doneCompleter.future;
    }

    Future<void> doClose() async {
      add(Dispose());

      _sendController.close();
      // _rawReceiveController and _transformedReceiveController are closed by the piped
      // receive streams being closed.

      // Give the combine worker time to shut down cleanly
      try {
        // Wait for disconnection confirmation.
        await firstWhere((message) => message is Disconnecting)
            .then(drain)
            .timeout(const Duration(seconds: 5));
      } on TimeoutException {
        logger.warning('Combine worker took too long to shut down, killing it');
        combineInfo.isolate.kill();
      }
    }

    _doneCompleter.complete(doClose());
    return _doneCompleter.future;
  }

  @override
  Future<void> get done => _doneCompleter.future;

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      throw UnimplementedError();

  @override
  Future<void> addStream(Stream<GatewayMessage> stream) => stream.forEach(add);
}

/// Data class for Combine worker spawning
class _CombineShardData extends ShardData {
  _CombineShardData({
    required super.totalShards,
    required super.id,
    required super.apiOptions,
    required super.originalConnectionUri,
  });
}
