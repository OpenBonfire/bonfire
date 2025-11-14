import 'dart:async';

import 'package:firebridge/src/client.dart';
import 'package:firebridge/src/models/voice_gateway/event.dart';
import 'package:firebridge/src/utils/iterable_extension.dart';
import 'package:firebridge/src/voice_gateway/voice_gateway.dart';

mixin VoiceEventMixin implements Nyxx {
  /// A [Stream] of gateway dispatch events received by this client.
  Stream<VoiceGatewayEvent> get onEvent => (this as VoiceGateway).events;

  StreamSubscription<T> on<T extends VoiceGatewayEvent>(
          void Function(T event) onData) =>
      onEvent.whereType<T>().listen(onData);

  /// A [Stream] of [ReadyEvent]s received by this client.
  Stream<VoiceReadyEvent> get onReady => onEvent.whereType<VoiceReadyEvent>();

  /// A [Stream] of [HelloEvent]s received by this client.
  Stream<VoiceHelloEvent> get onHello => onEvent.whereType<VoiceHelloEvent>();

  /// A [Stream] of [HeartbeatEvent]s received by this client.
  Stream<VoiceHeartbeatEvent> get onHeartbeat =>
      onEvent.whereType<VoiceHeartbeatEvent>();

  /// A [Stream] of [ResumedEvent]s received by this client.
  Stream<VoiceResumedEvent> get onResumed =>
      onEvent.whereType<VoiceResumedEvent>();

  /// A [Stream] of [VoiceSessionDescriptionEvent]s received by this client.
  Stream<VoiceSessionDescriptionEvent> get onVoiceSessionDescription =>
      onEvent.whereType<VoiceSessionDescriptionEvent>();

  /// A [Stream] of [VoiceSpeakingEvent]s received by this client.
  Stream<VoiceSessionUpdateEvent> get onVoiceSessionUpdate =>
      onEvent.whereType<VoiceSessionUpdateEvent>();

  /// A [Stream] of [VoiceSpeakingEvent]s received by this client.
  Stream<VoiceSpeakingEvent> get onSpeaking =>
      onEvent.whereType<VoiceSpeakingEvent>();

  Stream<VoiceClientDisconnectEvent> get onClientDisconnect =>
      onEvent.whereType<VoiceClientDisconnectEvent>();

  Stream<VoiceBackendVersionEvent> get onBackendVersion =>
      onEvent.whereType<VoiceBackendVersionEvent>();
}
