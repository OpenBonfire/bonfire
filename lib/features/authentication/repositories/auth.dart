import 'dart:convert';

import 'package:bonfire/features/authentication/controllers/ready.dart';
import 'package:bonfire/features/authentication/models/added_account.dart';
import 'package:bonfire/features/authentication/utils/headers.dart';
import 'package:bonfire/features/authentication/repositories/discord_auth.dart';
import 'package:bonfire/features/authentication/models/auth.dart';
import 'package:bonfire/features/events/utils/event_handler.dart';
import 'package:flutter/foundation.dart';
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
  bool isHandlingEvents = false;

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
    debugPrint("LOGGING IN WITH TOKEN!");
    AuthResponse response = AuthNotStarted();

    if (authResponse is AuthUser) {
      print("is auth user so is closing!");
      await (authResponse as AuthUser).client.close();
    }

    var client = await Nyxx.connectGatewayWithOptions(
        GatewayApiOptions(
          token: token,
          // totalShards: 1,
          intents: GatewayIntents.all,
          compression: UniversalPlatform.isWeb
              ? GatewayCompression.none
              : GatewayCompression.transport,
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

    // if (!isHandlingEvents) {
    handleEvents(ref, client);
    //   isHandlingEvents = true;
    // }

    ref.read(readyControllerProvider.notifier).setReady(true);

    final user = (await client.user.get());
    final addedAccountsBox = Hive.box('added-accounts');

    final addedAccount = AddedAccount(
      userId: client.user.id.toString(),
      token: token,
      username: user.globalName ?? user.username,
      avatar: user.avatar.url.toString(),
    );
    addedAccountsBox.put(client.user.id.toString(), addedAccount.toJson());

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
}
