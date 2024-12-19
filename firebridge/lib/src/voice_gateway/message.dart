import 'package:firebridge/src/models/voice_gateway/opcode.dart';
import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

abstract class VoiceGatewayMessage with ToStringHelper {}

abstract class VoiceMessage with ToStringHelper {}

/// A gateway message sent to instruct the shard to send data on its connection.
class VoiceSend extends VoiceGatewayMessage {
  /// The opcode of the event to send.
  final VoiceOpcode opcode;

  /// The data of the event to send.
  final dynamic data;

  /// Create a new [VoiceSend].
  VoiceSend({required this.opcode, required this.data});
}

/// A shard message sent when the shard adds a payload to the connection.
class VoiceSent extends VoiceMessage {
  /// The payload that was sent.
  final VoiceSend payload;

  /// Create a new [VoiceSent].
  VoiceSent({required this.payload});
}

/// {@template voice_data}
/// Information a shard needs to run itself.
/// {@endtemplate}
class VoiceData with ToStringHelper {
  final String sessionId;
  final String token;
  final Uri endpoint;

  /// {@macro voice_data}
  const VoiceData({
    required this.sessionId,
    required this.token,
    required this.endpoint,
  });
}

/// A shard message sent when the shard encounters an error.
class VoiceErrorReceived extends VoiceMessage {
  /// The error encountered.
  final Object error;

  /// The stack trace where the error occurred.
  final StackTrace stackTrace;

  /// Create a new [VoiceErrorReceived].
  VoiceErrorReceived({required this.error, required this.stackTrace});
}
