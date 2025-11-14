import 'dart:convert';

import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/client.dart';
import 'package:firebridge/src/http/request.dart';
import 'package:firebridge/src/http/route.dart';
import 'package:firebridge/src/models/gateway/events/notification.dart';
import 'package:firebridge/src/models/gateway/gateway.dart';
import 'package:firebridge/src/models/presence.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/utils/parsing_helpers.dart';

/// A [Manager] for gateway information.
// Use an abstract class so the client getter can be abstract,
// allowing us to override it in Gateway to have a more specific type.
abstract class GatewayManager {
  /// The client this manager is for.
  NyxxRest get client;

  /// @nodoc
  // We need a constructor to be allowed to use this class as a superclass.
  GatewayManager.create();

  /// Create a new [GatewayManager].
  factory GatewayManager(NyxxRest client) = _GatewayManagerImpl;

  GatewayConfiguration parseGatewayConfiguration(Map<String, Object?> raw) {
    return GatewayConfiguration(url: Uri.parse(raw['url'] as String));
  }

  GatewayBot parseGatewayBot(Map<String, Object?> raw) {
    return GatewayBot(
      url: Uri.parse(raw['url'] as String),
      shards: raw['shards'] as int,
      sessionStartLimit: parseSessionStartLimit(
          raw['session_start_limit'] as Map<String, Object?>),
    );
  }

  SessionStartLimit parseSessionStartLimit(Map<String, Object?> raw) {
    return SessionStartLimit(
      total: raw['total'] as int,
      remaining: raw['remaining'] as int,
      resetAfter: Duration(milliseconds: raw['reset_after'] as int),
      maxConcurrency: raw['max_concurrency'] as int,
    );
  }

  Activity parseActivity(Map<String, Object?> raw) {
    // No fields are validated server-side. Expect errors.
    return Activity(
      name: raw['name'] as String,
      type: ActivityType.parse(raw['type'] as int),
      url: tryParse(raw['url'], Uri.parse),
      createdAt:
          tryParse(raw['created_at'], DateTime.fromMillisecondsSinceEpoch),
      timestamps: tryParse(raw['timestamps'], parseActivityTimestamps),
      applicationId: tryParse(raw['application_id'], Snowflake.parse),
      details: tryParse(raw['details']),
      state: tryParse(raw['state']),
      emoji: tryParse(raw['emoji'], client.guilds[Snowflake.zero].emojis.parse),
      party: tryParse(raw['party'], parseActivityParty),
      assets: tryParse(raw['assets'], parseActivityAssets),
      secrets: tryParse(raw['secrets'], parseActivitySecrets),
      isInstance: tryParse(raw['instance']),
      flags: tryParse(raw['flags'], ActivityFlags.new),
      buttons: tryParseMany(raw['buttons'], parseActivityButton),
    );
  }

  ActivityTimestamps parseActivityTimestamps(Map<String, Object?> raw) {
    return ActivityTimestamps(
      start: maybeParse(
          raw['start'],
          (int milliseconds) =>
              DateTime.fromMillisecondsSinceEpoch(milliseconds)),
      end: maybeParse(
          raw['end'],
          (int milliseconds) =>
              DateTime.fromMillisecondsSinceEpoch(milliseconds)),
    );
  }

  ActivityParty parseActivityParty(Map<String, Object?> raw) {
    return ActivityParty(
      id: raw['id'] as String?,
      currentSize: (raw['size'] as List<Object?>?)?[0] as int?,
      maxSize: (raw['size'] as List<Object?>?)?[1] as int?,
    );
  }

  ActivityAssets parseActivityAssets(Map<String, Object?> raw) {
    return ActivityAssets(
      largeImage: raw['large_image'] as String?,
      largeText: raw['large_text'] as String?,
      smallImage: raw['small_image'] as String?,
      smallText: raw['small_text'] as String?,
    );
  }

  ActivitySecrets parseActivitySecrets(Map<String, Object?> raw) {
    return ActivitySecrets(
      join: raw['join'] as String?,
      spectate: raw['spectate'] as String?,
      match: raw['match'] as String?,
    );
  }

  ActivityButton parseActivityButton(Map<String, Object?> raw) {
    return ActivityButton(
      label: raw['label'] as String,
      url: Uri.parse(raw['url'] as String),
    );
  }

  ClientStatus parseClientStatus(Map<String, Object?> raw) {
    return ClientStatus(
      desktop: maybeParse(raw['desktop'], UserStatus.parse),
      mobile: maybeParse(raw['mobile'], UserStatus.parse),
      web: maybeParse(raw['web'], UserStatus.parse),
    );
  }

  /// Fetch the current gateway configuration.
  Future<GatewayConfiguration> fetchGatewayConfiguration() async {
    final route = HttpRoute()..gateway();
    final request = BasicRequest(route, authenticated: false);

    final response = await client.httpHandler.executeSafe(request);
    return parseGatewayConfiguration(response.jsonBody as Map<String, Object?>);
  }

  /// Fetch the current gateway configuration for the client.
  Future<GatewayBot> fetchGatewayBot() async {
    final route = HttpRoute()
      ..gateway()
      ..bot();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseGatewayBot(response.jsonBody as Map<String, Object?>);
  }

  /// Parse a [NotificationCreatedEvent] from a raw map.
  NotificationCreatedEvent parseNotificationCreated(Map<String, Object?> raw) {
    return NotificationCreatedEvent(
      userAvatar: raw['user_avatar'] as String,
      notifInstanceId: Snowflake.parse(raw['notif_instance_id'] as String),
      messageType: MessageType(int.parse(raw['message_type_'] as String)),
      username: raw['user_username'] as String,
      messageId: Snowflake.parse(raw['message_id'] as String),
      recievingUserId: Snowflake.parse(raw['receiving_user_id'] as String),
      eventType: raw['type'] as String,
      message: MessageManager(
        client.options.messageCacheConfig,
        client,
        channelId: Snowflake.parse(raw['channel_id']!),
      ).parse(jsonDecode(raw['message'] as String) as Map<String, Object?>),
      messageFlags: MessageFlags(int.parse(raw['message_flags'] as String)),
      messageContent: raw['message_content'] as String,
      userId: Snowflake.parse(raw['user_id'] as String),
      category: raw['__category'] as String,
      sound: raw['__sound'] as String,
      channelType: ChannelType.values[int.parse(raw['channel_type'] as String)],
      channelId: Snowflake.parse(raw['channel_id'] as String),
      notifTypeId: int.parse(raw['notif_type_id'] as String),
    );
  }
}

class _GatewayManagerImpl extends GatewayManager {
  @override
  final NyxxRest client;

  _GatewayManagerImpl(this.client) : super.create();
}
