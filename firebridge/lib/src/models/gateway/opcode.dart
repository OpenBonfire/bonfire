/// Opcodes sent or received over the Gateway.
enum Opcode {
  /// An event is dispatched to the client.
  dispatch._(0),

  /// Sent when heartbeating or received when requesting a heartbeat.
  heartbeat._(1),

  /// Sent when opening a Gateway session.
  identify._(2),

  /// Sent when updating the client's presence.
  presenceUpdate._(3),

  /// Sent when updating the client's voice state.
  voiceStateUpdate._(4),

  /// Send when resuming a Gateway session.
  resume._(6),

  /// Received when the client should reconnect.
  reconnect._(7),

  /// Sent to request guild members.
  requestGuildMembers._(8),

  /// Received when the client's session is invalid.
  invalidSession._(9),

  /// Received when the connection to the Gateway is opened.
  hello._(10),

  /// Received when the server receives the client's heartbeat.
  heartbeatAck._(11),

  /// Send to lazily request guild members.
  lazyRequestGuildMembers._(14),

  /// Sent when creating a stream.
  streamCreate._(18),

  /// Sent when deleting a stream.
  streamDelete._(19),

  /// Sent when watching a stream.
  streamWatch._(20),

  /// Sent to ping a stream.
  streamPing._(21),

  /// Sent to set a stream as paused.
  streamSetPaused._(22),

  /// Sent to request guild application commands.
  requestGuildApplicationCommands._(24),

  /// Sent to launch an embedded activity.
  embeddedActivityLaunch._(25),

  /// Sent to close an embedded activity.
  embeddedActivityClose._(26),

  /// Sent to update an embedded activity.
  embeddedActivityUpdate._(27),

  /// Sent to request forum unread messages.
  requestForumUnreads._(28),

  /// Sent for a remote command.
  remoteCommand._(29),

  /// Sent to get deleted entity IDs not matching a hash.
  getDeletedEntityIdsNotMatchingHash._(30),

  /// Sent to request soundboard sounds.
  requestSoundboardSounds._(31),

  /// Sent to create a speed test.
  speedTestCreate._(32),

  /// Sent to delete a speed test.
  speedTestDelete._(33),

  /// Sent to request last messages.
  requestLastMessages._(34),

  /// Sent to search recent members.
  searchRecentMembers._(35),

  /// Sent to request channel statuses.
  requestChannelStatuses._(36),

  /// Sent for bulk guild subscriptions.
  guildSubscriptionsBulk._(37);

  /// The value of this [Opcode].
  final int value;

  const Opcode._(this.value);
}

enum MemberListUpdateType {
  sync._("SYNC"),
  update._("UPDATE"),
  unknown._("UNKNOWN"),
  delete._("DELETE");

  final String value;

  const MemberListUpdateType._(this.value);
}
