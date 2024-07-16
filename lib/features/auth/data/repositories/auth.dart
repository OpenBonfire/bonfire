import 'dart:convert';

import 'package:bonfire/features/auth/data/headers.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:http/http.dart' as http;
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';

part 'auth.g.dart';

/// A riverpod provider that handles authentication with Discord.
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  NyxxGateway? client;
  AuthResponse? authResponse;

  @override
  AuthResponse? build() {
    return authResponse;
  }

  /// Authenticate client with Discord [username] and [password]
  Future<AuthResponse> loginWithCredentials(
      String username, String password, bool store) async {
    Map<String, Object?> body = {
      'gift_code_sku_id': null,
      'login': username,
      'login_source': null,
      'password': password,
      'undelete': false,
    };

    final response = await http.post(
      Uri.https("discord.com", '/api/v9/auth/login'),
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
      if (store == false) {
        state = authResponse;
      } else {
        // store in hive
        if (authResponse is AuthUser) {
          print("SAVING AUTH");
          var box = await Hive.openBox('added-accounts');
          box.put('username', username);
          box.put('token', authResponse.token);
        }
      }
    } else {
      throw Exception('Unknown response');
    }

    return authResponse;
  }

  /// Authenticate client with Discord [token]
  Future<AuthResponse> loginWithToken(String token) async {
    AuthResponse? response;

    var client = await Nyxx.connectGateway(token, GatewayIntents.all,
        options: GatewayClientOptions(
            plugins: [Logging(logLevel: Level.OFF), IgnoreExceptions()]));

    // This is how we save login information
    var box = await Hive.openBox('auth');
    box.put('token', token);

    // Save and notify state
    authResponse = AuthUser(token: token, client: client);
    state = authResponse!;

    client.onReady.listen((event) {
      ref
          .read(privateMessageHistoryProvider.notifier)
          .setMessageHistory(event.privateChannels);

      ref
          .read(guildFoldersProvider.notifier)
          .setGuildFolders(event.userSettings.guildFolders!);

      for (var readState in event.readStates) {
        ref
            .read(channelReadStateProvider(readState.channel.id).notifier)
            .setReadState(readState);
      }

      ref
          .read(userStatusStateProvider.notifier)
          .setUserStatus(event.userSettings.status!);

      ref.read(guildsStateProvider.notifier).setGuilds(event.guilds);

      if (event.userSettings.customStatus != null) {
        ref
            .read(customStatusStateProvider.notifier)
            .setCustomStatus(event.userSettings.customStatus!);
      }

      client.onChannelUnread.listen((event) {
        for (var element in event.channelUnreadUpdates) {
          ref
              .read(channelReadStateProvider(element.readState.channel.id)
                  .notifier)
              .setReadState(element.readState);
        }
      });

      client.onMessageAck.listen((event) {
        ref
            .read(channelReadStateProvider(event.readState.channel.id).notifier)
            .setReadState(event.readState);
      });
    });

    response = authResponse;

    return response!;
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
