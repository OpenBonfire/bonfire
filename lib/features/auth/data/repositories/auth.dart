import 'dart:convert';

import 'package:bonfire/features/auth/data/headers.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/me/controllers/settings.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      String username, String password) async {
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
      state = authResponse;
    } else {
      throw Exception('Unknown response');
    }

    return authResponse;
  }

  /// Authenticate client with Discord [token]
  Future<AuthResponse> loginWithToken(String token) async {
    var newClient = await Nyxx.connectGateway(token, GatewayIntents.all,
        options: GatewayClientOptions(
            plugins: [Logging(logLevel: Level.SEVERE), IgnoreExceptions()]));
    client = newClient;

    // This is how we save login information
    GetStorage().write('token', token);

    // Save and notify state
    authResponse = AuthUser(token: token, client: client!);
    state = authResponse!;

    client!.onReady.listen((event) {
      ref
          .read(privateMessageHistoryProvider.notifier)
          .setMessageHistory(event.privateChannels);

      ref
          .read(guildFoldersProvider.notifier)
          .setGuildFolders(event.userSettings.guildFolders);
    });

    client!.gateway.shards[0].done.then((value) {
      // not sure what to do with this, but it works so yeah
      // essentially, it signals shard disconnect
      print("Shard 0 done!");
      state = authResponse;
    });

    return authResponse!;
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
