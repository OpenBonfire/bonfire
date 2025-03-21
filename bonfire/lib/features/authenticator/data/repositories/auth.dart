import 'dart:convert';

import 'package:bonfire/features/authenticator/controllers/ready.dart';
import 'package:bonfire/features/authenticator/data/headers.dart';
import 'package:bonfire/features/authenticator/data/repositories/discord_auth.dart';
import 'package:bonfire/features/authenticator/models/auth.dart';
import 'package:bonfire/features/channels/controllers/channel.dart';
import 'package:bonfire/features/channels/repositories/channel_members.dart';
import 'package:bonfire/features/friends/controllers/relationships.dart';
import 'package:bonfire/features/guild/controllers/guild.dart';
import 'package:bonfire/features/guild/controllers/role.dart';
import 'package:bonfire/features/guild/controllers/roles.dart';
import 'package:bonfire/features/messaging/controllers/message.dart';
import 'package:bonfire/features/messaging/repositories/messages.dart';
import 'package:bonfire/features/messaging/repositories/reactions.dart';
import 'package:bonfire/features/user/controllers/presence.dart';
import 'package:bonfire/features/voice/repositories/voice_members.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:universal_platform/universal_platform.dart';

part 'auth.g.dart';

/// A riverpod provider that handles authentication with Discord.
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  NyxxGateway? client;
  AuthResponse? authResponse;
  bool hasSentInit = false;

  @override
  AuthResponse? build() {
    return authResponse;
  }

  /// Authenticate client with Discord [username] and [password]
  Future<AuthResponse> loginWithCredentials(
      String username, String password) async {
    Map<String, Object?> body = {
      'gift_code_sku_id': null,
      'login': username,
      'login_source': null,
      'password': password,
      'undelete': false,
    };

    Uri loginUrl = UniversalPlatform.isWeb
        ? Uri.https("cors-proxy.mylo-fawcett.workers.dev", "/",
            {'url': Uri.https("discord.com", '/api/v9/auth/login').toString()})
        : Uri.https("discord.com", '/api/v9/auth/login');

    final response = await http.post(
      loginUrl, //Uri.https("discord.com", '/api/v9/auth/login'),
      headers: Headers.getHeaders(),
      body: jsonEncode(body),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    AuthResponse authResponse;

    if (json.containsKey('user_id')) {
      if (json.containsKey("ticket")) {
        authResponse = MFARequired.fromJson(json);
        state = authResponse;
      } else {
        final authObj = AuthSuccess.fromJson(json);
        return await loginWithToken(authObj.token);
      }
    } else if (json.containsKey('captcha_key') &&
        json.containsKey('captcha_sitekey') &&
        json.containsKey('captcha_service')) {
      authResponse = CaptchaResponse.fromJson(json);
      state = authResponse;
    } else if (json['errors']['login']['_errors'][0]['code'] ==
        'INVALID_LOGIN') {
      authResponse =
          FailedAuth(error: json['errors']['login']['_errors'][0]['message']);
      state = authResponse;
    } else {
      throw Exception('Unknown response');
    }

    return authResponse;
  }

  /// Authenticate client with Discord [token]
  Future<AuthResponse> loginWithToken(String token) async {
    print("LOGGING IN WITH TOKEN!");
    AuthResponse response = AuthNotStarted();

    var client = await Nyxx.connectGatewayWithOptions(
        GatewayApiOptions(
          token: token,
          intents: GatewayIntents.all,
          compression: GatewayCompression.none,
        ),
        GatewayClientOptions(
          plugins: [
            Logging(logLevel: Level.SEVERE),
          ],
        ));

    // This is how we save login information
    var box = await Hive.openBox('auth');
    box.put('token', token);

    // Save and notify state
    authResponse = AuthUser(token: token, client: client);
    state = authResponse!;

    void testPushNotifications() async {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      client.users
          .registerNotificationDevice(PushNotificationProvider.gcm, fcmToken!);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
      // FirebaseMessaging.onBackgroundMessage((message) async {
      //   print("Handling a background message: ${message.messageId}");
      // });
    }

    client.onReady.listen((event) {
      // if (hasSentInit) return;
      // hasSentInit = true;

      if (UniversalPlatform.isMobile) testPushNotifications();

      // print("Closing!!");
      // client.close();
      // final notificationData =
      //     client.gateway.parseNotificationCreated(testData);

      // print("parsed!");

      print("READY!");

      for (var guild in event.guilds) {
        // channels
        for (var channel in guild.channels ?? []) {
          ref
              .read(channelControllerProvider(channel.id).notifier)
              .setChannel(channel);
        }

        // roles
        List<Snowflake> roleIds = [];
        for (var role in guild.roleList) {
          ref.read(roleControllerProvider(role.id).notifier).setRole(role);
          roleIds.add(role.id);
        }
        ref.read(rolesControllerProvider(guild.id).notifier).setRoles(roleIds);

        // we want this backwards in case we have initializers that depend on guild channels
        // if a flow goes like
        // get guild -> get channels -> get messages
        // this would error if we intuitively initialize it first
        ref.read(guildControllerProvider(guild.id).notifier).setGuild(guild);
      }

      ref.read(guildsStateProvider.notifier).setGuilds(event.guilds);

      ref
          .read(privateMessageHistoryProvider.notifier)
          .setMessageHistory(event.privateChannels);

      for (var channel in event.privateChannels) {
        ref
            .read(channelControllerProvider(channel.id).notifier)
            .setChannel(channel);
      }

      ref
          .read(guildFoldersProvider.notifier)
          .setGuildFolders(event.userSettings.guildFolders!);

      for (var readState in event.readStates) {
        ref
            .read(channelReadStateProvider(readState.channel.id).notifier)
            .setReadState(readState);
      }

      ref
          .read(selfStatusStateProvider.notifier)
          .setSelfStatus(event.userSettings.status!);

      ref
          .read(relationshipControllerProvider.notifier)
          .setRelationships(event.relationships);

      for (var presence in event.presences) {
        if (presence.user == null) continue;
        ref
            .read(presenceControllerProvider(presence.user!.id).notifier)
            .setPresence(presence);
      }

      if (event.userSettings.customStatus != null) {
        ref
            .read(customStatusStateProvider.notifier)
            .setCustomStatus(event.userSettings.customStatus!);
      }
    });

    client.onMessageCreate.listen((event) {
      ref
          .read(messageControllerProvider(event.message.id).notifier)
          .setMessage(event.message);

      ref
          .read(messagesProvider(event.message.channelId).notifier)
          .processMessage(event.message);
    });

    client.onPresenceUpdate.listen((event) {
      ref
          .watch(presenceControllerProvider(event.user!.id).notifier)
          .setPresence(event);
    });

    client.onChannelUnread.listen((event) {
      for (var element in event.channelUnreadUpdates) {
        ref
            .read(
                channelReadStateProvider(element.readState.channel.id).notifier)
            .setReadState(element.readState);
      }
    });

    client.onMessageAck.listen((event) {
      ref
          .read(channelReadStateProvider(event.readState.channel.id).notifier)
          .setReadState(event.readState);
    });

    client.onVoiceStateUpdate.listen((event) {
      ref
          .read(voiceMembersProvider(event.state.guildId!).notifier)
          .processVoiceStateUpdate(event);
      ref
          .read(
            voiceMembersProvider(
              event.state.guildId!,
              channelId: event.state.channelId ?? event.oldState?.channelId,
            ).notifier,
          )
          .processVoiceStateUpdate(event);
    });

    client.onPresenceUpdate.listen((event) {
      if (event.status != null) {
        ref
            .read(UserStatusStateProvider(event.user!.id).notifier)
            .setUserStatus(event.status!);
      }
      if (event.activities != null) {
        ref
            .read(UserActivityStateProvider(event.user!.id).notifier)
            .setUserActivity(event.activities!);
      }
    });

    client.onGuildMemberListUpdate.listen((event) {
      ref
          .read(channelMembersProvider.notifier)
          .updateMemberList(event.operations, event.guildId, event.groups);
    });

    client.onRelationshipAdd.listen((event) {
      // TODO: handle shouldNotify
      ref
          .read(relationshipControllerProvider.notifier)
          .addRelationship(event.relationship);
    });

    client.onRelationshipRemove.listen((event) {
      ref
          .read(relationshipControllerProvider.notifier)
          .removeRelationship(event.id);
    });

    client.onMessageReactionAdd.listen((event) {
      ref
          .read(messageReactionsProvider(event.messageId).notifier)
          .addReaction(event.emoji, event.user, event.burstColors);
    });

    client.onMessageReactionRemove.listen((event) {
      ref
          .read(messageReactionsProvider(event.messageId).notifier)
          .removeReaction(event.emoji, event.user);
    });

    ref.read(readyControllerProvider.notifier).setReady(true);

    return response;
  }

  /// Submit captcha with [captchaKey] and [captchaToken]
  Future<bool> submitCaptcha(String captchaKey, String captchaToken) async {
    return true;
  }

  /// Submit multi-factor authentication with [mfaToken]
  Future<AuthResponse> submitMfa(String mfaToken) async {
    var body = {
      'code': int.parse(mfaToken),
      'gift_code_sku_id': null,
      'login_source': null,
      'ticket': (state as MFARequired).ticket,
    };

    final response = await http.post(
      Uri.https("discord.com", '/api/v9/auth/mfa/totp'),
      headers: Headers.getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var resp = AuthSuccess.fromJson(jsonDecode(response.body));
      return loginWithToken(resp.token);
    } else if (response.statusCode == 400) {
      return MFAInvalidError(error: "Invalid two-factor code");
    } else {
      return FailedAuth(error: response.body);
    }
  }

  /// Submit sms authentication with [phoneToken]
  Future<bool> submitPhoneAuth(String phoneToken) async {
    return true;
  }

  /// Get the current authentication state
  ///
  /// Returns [AuthResponse] if authenticated, otherwise null
  AuthResponse? getAuth() {
    return authResponse;
  }
}
