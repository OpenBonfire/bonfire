import 'dart:async';
import 'dart:convert';

import 'package:firebridge/src/builders/application_role_connection.dart';
import 'package:firebridge/src/builders/user.dart';
import 'package:firebridge/src/http/managers/manager.dart';
import 'package:firebridge/src/http/request.dart';
import 'package:firebridge/src/http/route.dart';
import 'package:firebridge/src/models/channel/channel.dart';
import 'package:firebridge/src/models/channel/text_channel.dart';
import 'package:firebridge/src/models/channel/types/dm.dart';
import 'package:firebridge/src/models/channel/types/group_dm.dart';
import 'package:firebridge/src/models/discord_color.dart';
import 'package:firebridge/src/models/guild/guild.dart';
import 'package:firebridge/src/models/guild/integration.dart';
import 'package:firebridge/src/models/guild/member.dart';
import 'package:firebridge/src/models/locale.dart';
import 'package:firebridge/src/models/message/message.dart';
import 'package:firebridge/src/models/presence.dart';
import 'package:firebridge/src/models/snowflake.dart';
import 'package:firebridge/src/models/user/application_role_connection.dart';
import 'package:firebridge/src/models/user/connection.dart';
import 'package:firebridge/src/models/user/notification.dart';
import 'package:firebridge/src/models/user/profile_badge.dart';
import 'package:firebridge/src/models/user/profile_effect.dart';
import 'package:firebridge/src/models/user/profile_metadata.dart';
import 'package:firebridge/src/models/user/relationship.dart';
import 'package:firebridge/src/models/user/settings/custom_status.dart';
import 'package:firebridge/src/models/user/settings/guild_folder.dart';
import 'package:firebridge/src/models/user/settings/read_state.dart';
import 'package:firebridge/src/models/user/settings/user_guild_settings.dart';
import 'package:firebridge/src/models/user/settings/user_settings.dart';
import 'package:firebridge/src/models/user/user.dart';
import 'package:firebridge/src/models/user/user_profile.dart';
import 'package:firebridge/src/utils/cache_helpers.dart';
import 'package:firebridge/src/utils/date.dart';
import 'package:firebridge/src/utils/parsing_helpers.dart';

/// A manager for [User]s.
class UserManager extends ReadOnlyManager<User> {
  /// Create a new [UserManager].
  UserManager(super.config, super.client) : super(identifier: 'users');

  @override
  PartialUser operator [](Snowflake id) => PartialUser(id: id, manager: this);

  @override
  User parse(Map<String, Object?> raw) {
    final hasAccentColor = raw['accent_color'] != null;
    final hasLocale = raw['locale'] != null;
    final hasFlags = raw['flags'] != null;
    final hasPremiumType = raw['premium_type'] != null;
    final hasPublicFlags = raw['public_flags'] != null;

    return User(
      manager: this,
      id: Snowflake.parse(raw['id']!),
      username: raw['username'] as String,
      discriminator: raw['discriminator'] as String,
      globalName: raw['global_name'] as String?,
      avatarHash: raw['avatar'] as String?,
      isBot: raw['bot'] as bool? ?? false,
      isSystem: raw['system'] as bool? ?? false,
      hasMfaEnabled: raw['mfa_enabled'] as bool? ?? false,
      bannerHash: raw['banner'] as String?,
      accentColor:
          hasAccentColor ? DiscordColor(raw['accent_color'] as int) : null,
      locale: hasLocale ? Locale.parse(raw['locale'] as String) : null,
      flags: hasFlags ? UserFlags(raw['flags'] as int) : null,
      nitroType: hasPremiumType
          ? NitroType.parse(raw['premium_type'] as int)
          : NitroType.none,
      publicFlags:
          hasPublicFlags ? UserFlags(raw['public_flags'] as int) : null,
      avatarDecorationHash: raw['avatar_decoration'] as String?,
    );
  }

  /// Parse a [Connection] from [raw].
  Connection parseConnection(Map<String, Object?> raw) {
    return Connection(
      id: raw['id'] as String,
      name: raw['name'] as String,
      type: ConnectionType.parse(raw['type'] as String),
      isRevoked: raw['revoked'] as bool?,
      integrations: maybeParseMany(
        raw['integrations'],
        (Map<String, Object?> raw) => PartialIntegration(
          id: Snowflake.parse(raw['id']!),

          // TODO: Can we know what guild the integrations are from?
          manager: client.guilds[Snowflake.zero].integrations,
        ),
      ),
      isVerified: raw['verified'] as bool,
      isFriendSyncEnabled: raw['friend_sync'] as bool,
      showActivity: raw['show_activity'] as bool,
      isTwoWayLink: raw['two_way_link'] as bool,
      visibility: ConnectionVisibility.parse(raw['visibility'] as int),
    );
  }

  UserSettings parseUserSettings(Map<String, Object?> raw) {
    return UserSettings(
      detectPlatformAccounts: raw['detect_platform_accounts'] as bool?,
      animateStickers: raw['animate_stickers'] as int?,
      inlineAttachmentMedia: raw['inline_attachment_media'] as bool?,
      status: tryParse(raw['status'] as String?, UserStatus.parse),
      messageDisplayCompact: raw['message_display_compact'] as bool?,
      viewNsfwGuilds: raw['view_nsfw_guilds'] as bool?,
      timezoneOffset: raw['timezone_offset'] as int?,
      enableTtsCommand: raw['enable_tts_command'] as bool?,
      disableGamesTab: raw['disable_games_tab'] as bool?,
      streamNotificationsEnabled: raw['stream_notifications_enabled'] as bool?,
      animateEmoji: raw['animate_emoji'] as bool?,
      guildFolders: tryParseMany(
          raw['guild_folders'] as List<Object?>?,
          (Map<String, Object?> raw) => GuildFolder(
                name: raw['name'] as String?,
                color: raw['color'] as int?,
                id: tryParse(raw['id'], Snowflake.parse),
                guildIds: parseMany(
                  raw['guild_ids'] as List<Object?>,
                  (Object? raw) => Snowflake.parse(raw as String),
                ),
              )),
      customStatus: raw['custom_status'] == null
          ? null
          : CustomStatus(
              text: (raw['custom_status'] as Map<String, Object?>)['text']
                  as String?,
              expiresAt: maybeParse(
                  (raw['custom_status'] as Map<String, Object?>)['expires_at'],
                  DateTime.parse),
              emojiName: (raw['custom_status']
                  as Map<String, Object?>)['emoji_name'] as String?,
              emojiId: (raw['custom_status']
                  as Map<String, Object?>)['emoji_id'] as String?,
            ),
    );
  }

  UserGuildSettings parseUserGuildSettings(Map<String, Object?> raw) {
    return UserGuildSettings(
      version: raw['version'] as int,
      suppressRoles: raw['suppress_roles'] as bool,
      suppressEveryone: raw['suppress_everyone'] as bool,
      notifyHighlights: raw['notify_highlights'] as int,
      muted: raw['muted'] as bool,
      muteScheduledEvents: raw['mute_scheduled_events'] as bool,
      muteConfig: raw['mute_config'],
      mobilePush: raw['mobile_push'] as bool,
      messageNotifications: raw['message_notifications'] as int,
      hideMutedChannels: raw['hide_muted_channels'] as bool,
      partialGuild: tryParse(raw['guild_id'], (String raw) {
        return PartialGuild(
          id: Snowflake.parse(raw),
          manager: client.guilds,
        );
      }),
      flags: raw['flags'] as int,
      channelOverrides: raw['channel_overrides'] as List<dynamic>,
    );
  }

  ReadState parseReadState(Map<String, Object?> raw) {
    return ReadState(
      mentionCount: raw['mention_count'] as int?,
      lastViewed: (raw["last_viewed"] != null)
          ? DiscordDateUtils.unpackLastViewed(raw["last_viewed"] as int)
          : null,
      lastPinTimestamp: DateTime.parse(raw['last_pin_timestamp'] as String),
      lastMessage: (raw['last_message_id'] != null)
          ? PartialMessage(
              id: Snowflake.parse(raw['last_message_id'].toString()),
              manager: (client.channels[Snowflake.zero] as PartialTextChannel)
                  .messages)
          : null,
      channel: PartialChannel(
        id: Snowflake.parse(raw['id'] as String),
        manager: client.channels,
      ),
      flags: raw['flags'] as int,
    );
  }

  Relationship parseRelationship(Map<String, Object?> raw) {
    return Relationship(
      user: parse(raw['user'] as Map<String, Object?>),
      type: raw['type'] as int,
      isSpamRequest: raw['is_spam_request'] as bool,
      id: Snowflake.parse(raw['id'] as String),
      nickname: raw['nickname'] as String?,
      since:
          raw['since'] == null ? null : DateTime.parse(raw['since'] as String),
    );
  }

  /// Parse a [ApplicationRoleConnection] from [raw].
  ApplicationRoleConnection parseApplicationRoleConnection(
      Map<String, Object?> raw) {
    return ApplicationRoleConnection(
      platformName: raw['platform_name'] as String?,
      platformUsername: raw['platform_username'] as String?,
      metadata: (raw['metadata'] as Map).cast<String, String>(),
    );
  }

  /// Parse a [PushSyncToken] from [raw].
  PushSyncToken parsePushSyncToken(Map<String, Object?> raw) {
    return PushSyncToken(raw['token'] as String);
  }

  ProfileMetadata parseProfileMetadata(Map<String, Object?> raw) {
    return ProfileMetadata(
      guildId: tryParse(raw['guild_id'], Snowflake.parse),
      pronouns: raw['pronouns'] as String,
      bio: raw['bio'] as String?,
      bannerHash: raw['banner'] as String?,
      // TODO: I think this is a DiscordColor. Cast to it as such.
      accentColor: raw['accent_color'] as int?,
      themeColors: raw['theme_colors'] as List<dynamic>?,
      popoutAnimationParticleType:
          tryParse(raw['popout_animation_particle_type'], Snowflake.parse),
      // TODO: parse emojis
      // emoji: tryParse(raw['emoji'], client.),
      profileEffect:
          tryParse(raw['profile_effect'], (Map<String, Object?> raw) {
        return ProfileEffect(
          id: Snowflake.parse(raw['id'] as String),
          expiresAt: DateTime.tryParse(raw['expires_at'] as String? ?? ""),
        );
      }),
    );
  }

  ProfileBadge parseProfileBadge(Map<String, Object?> raw) {
    return ProfileBadge(
      id: raw['id'] as String,
      description: raw['description'] as String,
      iconHash: raw['icon'] as String,
      link: tryParse(raw['link'], Uri.parse),
    );
  }

  ProfileEffectPosition parseProfileEffectPosition(Map<String, Object?> raw) {
    return ProfileEffectPosition(
      x: raw["x"] as int,
      y: raw["y"] as int,
    );
  }

  ProfileEffectAnimation parseProfileEffectAnimation(Map<String, Object?> raw) {
    return ProfileEffectAnimation(
        src: raw["src"] as String,
        loop: raw["loop"] as bool,
        height: raw["height"] as int,
        width: raw["width"] as int,
        duration: raw["duration"] as int,
        start: raw["start"] as int,
        loopDelay: raw["loopDelay"] as int,
        position:
            parseProfileEffectPosition(raw["position"] as Map<String, Object?>),
        zIndex: raw["zIndex"] as int);
  }

  ProfileEffectConfig parseProfileEffectConfig(Map<String, Object?> raw) {
    return ProfileEffectConfig(
      id: Snowflake.parse(raw["id"] as String),
      type: raw["type"] as int,
      skuId: raw["sku_id"] as String,
      title: raw["title"] as String,
      description: raw["description"] as String,
      accessibilityLabel: raw["accessibilityLabel"] as String,
      animationType: raw["animationType"] as int,
      thumnbnailPreviewSrc: raw["thumbnailPreviewSrc"] as String,
      reducedMotionSrc: raw["reducedMotionSrc"] as String,
      effects: parseMany(
        raw["effects"] as List<dynamic>,
        (Object? raw) =>
            parseProfileEffectAnimation(raw as Map<String, Object?>),
      ),
    );
  }

  ProfileEffect parseProfileEffect(Map<String, Object?> raw) {
    return ProfileEffect(
        id: Snowflake.parse(raw["id"] as String),
        expiresAt: DateTime.tryParse(raw["expires_at"] as String? ?? ""));
  }

  UserProfile parseUserProfile(Map<String, Object?> raw) {
    return UserProfile(
      user: parse(raw['user'] as Map<String, Object?>),
      userProfile:
          parseProfileMetadata(raw['user_profile'] as Map<String, Object?>),
      badges: parseMany(
        raw['badges'] as List<Object?>,
        (Object? raw) => parseProfileBadge(raw as Map<String, Object?>),
      ),
      guildBadges: parseMany(
        raw['guild_badges'] as List<Object?>,
        (Object? raw) => parseProfileBadge(raw as Map<String, Object?>),
      ),
      guildMember: tryParse(
        raw['guild_member'] as Map<String, Object?>?,
        (Map<String, Object?> raw) => client
            .guilds[Snowflake.parse(raw['guild_id'] as String)].members
            .parse(
          raw,
          userId: client.user.id,
        ),
      ),
      mutualFriends: parseMany(
        raw['mutual_friends'] as List<dynamic>? ?? [],
        (Object? raw) => parse(raw as Map<String, Object?>),
      ),
      mutualFriendsCount: raw['mutual_friends_count'] as int?,
      legacyUsername: raw['legacy_username'] as String?,
      connections: tryParseMany(
        raw['connections'] as List<Connection>?,
        (Object? raw) => parseConnection(raw as Map<String, Object?>),
      ),
      applicationRoleConnections: tryParseMany(
        raw['application_role_connections'] as List<ApplicationRoleConnection>?,
        (Object? raw) => parseApplicationRoleConnection(
          raw as Map<String, Object?>,
        ),
      ),
      // TODO: Parse applications
      // application: tryParse(
      //   raw['application'] as Map<String, Object?>?,
      //   (Map<String, Object?> raw) =>
      // ),
      // TODO: Make NitroType
      premiumType: raw['premium_type'] as num?,
      premiumSince: (raw['premium_since'] != null)
          ? DateTime.parse(raw['premium_since'] as String)
          : null,
      premiumGuildSince: (raw['premium_guild_since'] != null)
          ? DateTime.parse(raw['premium_guild_since'] as String)
          : null,
    );
  }

  Future<List<ProfileEffectConfig>> fetchProfileEffects() async {
    final route = HttpRoute()..userProfileEffects();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final profileEffectConfig = parseMany(
        response.jsonBody["profile_effect_configs"] as List<dynamic>,
        (Map<String, Object?> raw) => parseProfileEffectConfig(raw));

    return profileEffectConfig;
  }

  @override
  Future<User> fetch(Snowflake id) async {
    final route = HttpRoute()..users(id: id.toString());
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final user = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(user);
    return user;
  }

  /// Fetch the current user from the API.
  Future<User> fetchCurrentUser() async {
    final route = HttpRoute()..users(id: '@me');
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final user = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(user);
    return user;
  }

  /// Update the current user.
  Future<User> updateCurrentUser(UserUpdateBuilder builder) async {
    final route = HttpRoute()..users(id: '@me');
    final request = BasicRequest(
      route,
      method: 'PATCH',
      body: jsonEncode(builder.build()),
    );

    final response = await client.httpHandler.executeSafe(request);
    final user = parse(response.jsonBody as Map<String, Object?>);

    client.updateCacheWith(user);
    return user;
  }

  /// List the guilds the current user is a member of.
  Future<List<UserGuild>> listCurrentUserGuilds(
      {Snowflake? after,
      Snowflake? before,
      int? limit,
      bool? withCounts}) async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..guilds();
    final request = BasicRequest(route, queryParameters: {
      if (before != null) 'before': before.toString(),
      if (after != null) 'after': after.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (withCounts != null) 'with_counts': withCounts.toString(),
    });

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(
      response.jsonBody as List,
      (Map<String, Object?> raw) => client.guilds.parseUserGuild(raw),
    );
  }

  /// Fetch the current user's member for a guild.
  Future<Member> fetchCurrentUserMember(Snowflake guildId) async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..guilds(id: guildId.toString())
      ..member();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final member = client.guilds[guildId].members.parse(
        response.jsonBody as Map<String, Object?>,
        userId: client.user.id);

    client.updateCacheWith(member);
    return member;
  }

  /// Fetch a user's profile
  Future<UserProfile> fetchUserProfile(
    Snowflake userId, {
    bool withMutualGuilds = false,
    bool withMutualFriends = false,
    bool withMutualFriendsCount = false,
    String? friendToken,
    Snowflake? guildId,
    Snowflake? connectionsRoleId,
    Snowflake? joinRequestId,
  }) async {
    final route = HttpRoute()
      ..users(id: userId.toString())
      ..profile();
    final request = BasicRequest(route, queryParameters: {
      "type": "popout",
      "with_mutual_guilds": withMutualGuilds.toString(),
      "with_mutual_friends": withMutualFriends.toString(),
      "with_mutual_friends_count": withMutualFriendsCount.toString(),
      if (friendToken != null) "friend_token": friendToken,
      if (guildId != null) "guild_id": guildId.toString(),
      if (connectionsRoleId != null)
        "connections_role_id": connectionsRoleId.toString(),
      if (joinRequestId != null) "join_request_id": joinRequestId.toString()
    });

    final response = await client.httpHandler.executeSafe(request);
    final profile = client.users
        .parseUserProfile(response.jsonBody as Map<String, Object?>);
    return profile;
  }

  /// Leave a guild.
  Future<void> leaveGuild(Snowflake guildId) async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..guilds(id: guildId.toString());
    final request = BasicRequest(route, method: 'DELETE');

    await client.httpHandler.executeSafe(request);
  }

  /// Create a DM channel with another user.
  Future<DmChannel> createDm(Snowflake recipientId) async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..channels();
    final request = BasicRequest(route,
        method: 'POST',
        body: jsonEncode({'recipient_id': recipientId.toString()}));

    final response = await client.httpHandler.executeSafe(request);
    final channel = client.channels
        .parse(response.jsonBody as Map<String, Object?>) as DmChannel;

    client.updateCacheWith(channel);
    return channel;
  }

  /// Create a DM channel with multiple other users.
  Future<GroupDmChannel> createGroupDm(
      List<String> tokens, Map<Snowflake, String> nicks) async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..channels();
    final request = BasicRequest(
      route,
      method: 'POST',
      body: jsonEncode({
        'access_tokens': tokens,
        'nicks': {
          for (final entry in nicks.entries) entry.key.toString(): entry.value,
        }
      }),
    );

    final response = await client.httpHandler.executeSafe(request);
    final channel = client.channels
        .parse(response.jsonBody as Map<String, Object?>) as GroupDmChannel;

    client.updateCacheWith(channel);
    return channel;
  }

  /// Fetch the current user's connections.
  Future<List<Connection>> fetchCurrentUserConnections() async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..connections();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    final rawObjects = response.jsonBody as List;

    return List.generate(
      rawObjects.length,
      (index) => parseConnection(rawObjects[index] as Map<String, Object?>),
    );
  }

  /// Fetch the current user's application role connection for an application.
  Future<ApplicationRoleConnection> fetchCurrentUserApplicationRoleConnection(
      Snowflake applicationId) async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..applications(id: applicationId.toString())
      ..roleConnection();
    final request = BasicRequest(route);

    final response = await client.httpHandler.executeSafe(request);
    return parseApplicationRoleConnection(
        response.jsonBody as Map<String, Object?>);
  }

  /// Update the current user's application role connection for an application.
  Future<ApplicationRoleConnection> updateCurrentUserApplicationRoleConnection(
      Snowflake applicationId,
      ApplicationRoleConnectionUpdateBuilder builder) async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..applications(id: applicationId.toString())
      ..roleConnection();
    final request =
        BasicRequest(route, method: 'PUT', body: jsonEncode(builder.build()));

    final response = await client.httpHandler.executeSafe(request);
    return parseApplicationRoleConnection(
        response.jsonBody as Map<String, Object?>);
  }

  /// Registers a GCM/APNs push notification token for the client's device.
  Future<void> registerNotificationDevice(
    /// The push notification provider of the device
    PushNotificationProvider provider,

    /// The push notification token to register
    String token, {
    /// The push notification provider of the device
    PushNotificationProvider? voidProvider,

    /// The push notification token to register
    PushNotificationProvider? voipToken,
  }) async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..devices();
    final request = BasicRequest(route,
        method: 'POST',
        body: jsonEncode({
          'provider': provider.value,
          'token': token,
          'void_provider': voidProvider?.value,
          'voip_token': voipToken?.value,
        }));

    await client.httpHandler.executeSafe(request);
  }

  /// Unregisters a GCM/APNs push notification token for the client's device.
  Future<void> unregisterNotificationDevice(
    /// The push notification provider of the device
    PushNotificationProvider provider,

    /// The push notification token to register
    String token,
  ) async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..devices();
    final request = BasicRequest(route,
        method: 'DELETE',
        body: jsonEncode({
          'provider': provider.value,
          'token': token,
        }));

    await client.httpHandler.executeSafe(request);
  }

  Future<PushSyncToken> getDevicePushSyncToken() {
    final route = HttpRoute()
      ..users(id: '@me')
      ..devices()
      ..syncToken();
    final request = BasicRequest(route);

    return client.httpHandler.execute(request).then((response) {
      return parsePushSyncToken(response.jsonBody as Map<String, Object?>);
    });
  }

  Future<List<PushSyncToken>> syncDevices(
    /// The push notification provider of the device
    PushNotificationProvider provider,

    /// The push notification token to register
    String token,

    /// Device sync tokens for each account
    List<PushSyncToken> tokens,
  ) async {
    final route = HttpRoute()
      ..users(id: '@me')
      ..devices()
      ..sync();
    final request = BasicRequest(route,
        method: 'POST',
        body: jsonEncode({
          'provider': provider.value,
          'token': token,
          'tokens': tokens.map((e) => e.token).toList(),
        }));

    final response = await client.httpHandler.executeSafe(request);
    return parseMany(
      response.jsonBody as List,
      (Map<String, Object?> raw) => parsePushSyncToken(raw),
    );
  }
}
