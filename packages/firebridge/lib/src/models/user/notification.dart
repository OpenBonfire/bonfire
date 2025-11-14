/// Push notification provider for Mobile.
/// https://docs.discord.sex/topics/push-notifications
enum PushNotificationProvider {
  /// Google Cloud Messaging (Android)
  gcm._('gcm'),

  /// Apple Push Notification Service (iOS)
  apns._('apns'),

  /// Apple Push Notification Service (iOS internal)
  apnsInternal._('apns_internal'),

  /// VOIP Apple Push Notification Service (iOS)
  apnsVoip._('apns_voip'),

  /// VOIP Apple Push Notification Service (iOS internal)
  apnsInternalVoip._('apns_internal_voip');

  /// The value of this [PushNotificationProvider].
  final String value;

  const PushNotificationProvider._(this.value);

  @override
  String toString() => value;
}

/// Used to synchronize push notification tokens across multiple accounts.
class PushSyncToken {
  final String token;

  PushSyncToken(this.token);
}
