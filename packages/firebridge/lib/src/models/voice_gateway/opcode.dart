/// Opcodes sent or received over Voice
enum VoiceOpcode {
  /// Start a new voice WebSocket connection.
  identify._(0),

  /// Select the voice protocol.
  selectProtocol._(1),

  /// Complete the WebSocket handshake.
  ready._(2),

  /// Keep the WebSocket connection alive.
  heartbeat._(3),

  /// Describe the session.
  sessionDescription._(4),

  /// Indicate which users are speaking.
  speaking._(5),

  /// Response to receiving a heartbeat to acknowledge that it has been received.
  heartbeatAck._(6),

  /// Resume a previous session that was disconnected.
  resume._(7),

  /// Sent immediately after connecting, contains the heartbeat_interval to use.
  hello._(8),

  /// Response to acknowledging a successful resume.
  resumed._(9),

  /// Describe the video session.
  video._(12),

  /// A client has disconnected from the voice channel.
  clientDisconnect._(13),

  /// Update in session description.
  sessionUpdate._(14),

  /// Version information about the voice backend.
  voiceBackendVersion._(16),

  /// Receive
  channelOptionsUpdate._(17);

  /// The value of this [Opcode].
  final int value;

  const VoiceOpcode._(this.value);
}
