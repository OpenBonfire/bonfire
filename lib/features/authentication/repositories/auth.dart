import 'dart:convert';

import 'package:bonfire/features/authentication/controllers/ready.dart';
import 'package:bonfire/features/authentication/utils/headers.dart';
import 'package:bonfire/features/authentication/models/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_ce/hive.dart';
import 'package:universal_platform/universal_platform.dart';

part 'auth.g.dart';

/// A riverpod provider that handles authentication with Discord.
@Riverpod(keepAlive: true)
class ClientController extends _$ClientController {
  FirebridgeGateway? client;
  bool hasSentInit = false;
  bool isHandlingEvents = false;

  @override
  FirebridgeGateway? build() {
    return null;
  }

  /// Authenticate client with Discord [username] and [password]
  Future<FirebridgeGateway> loginWithCredentials(
    String username,
    String password,
  ) async {
    Map<String, Object?> body = {
      'gift_code_sku_id': null,
      'login': username,
      'login_source': null,
      'password': password,
      'undelete': false,
    };

    Uri loginUrl = Uri.https("discord.com", '/api/v9/auth/login');

    final response = await http.post(
      loginUrl, //Uri.https("discord.com", '/api/v9/auth/login'),
      headers: Headers.getHeaders(),
      body: jsonEncode(body),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json.containsKey('user_id')) {
      if (json.containsKey("ticket")) {
        throw Exception("Requires MFA");
      } else {
        final authObj = AuthSuccessMapper.fromMap(json);
        return await loginWithToken(authObj.token);
      }
    } else if (json.containsKey('captcha_key') &&
        json.containsKey('captcha_sitekey') &&
        json.containsKey('captcha_service')) {
      throw Exception("Requires Captcha");
    } else if (json['errors']['login']['_errors'][0]['code'] ==
        'INVALID_LOGIN') {
      throw Exception("Invalid Login");
    } else {
      throw Exception('Unknown response');
    }
  }

  /// Authenticate client with Discord [token]
  Future<FirebridgeGateway> loginWithToken(String token) async {
    debugPrint("LOGGING IN WITH TOKEN!");

    final client = await Firebridge.connectGatewayWithOptions(
      GatewayApiOptions(
        token: token,
        // totalShards: 1,
        compression: UniversalPlatform.isWeb
            ? GatewayCompression.none
            : GatewayCompression.transport,
      ),
      GatewayClientOptions(plugins: [Logging(logLevel: Level.INFO)]),
    );

    // await for (final MessageCreateEvent(:message) in client.onMessageCreate) {
    //   print('${message.id} sent by ${message.author.id} in ${message.id}!');
    // }

    // This is how we save login information
    final box = await Hive.openBox('auth');
    box.put('token', token);

    // Save and notify state
    state = client;

    // if (!isHandlingEvents) {
    // handleEvents(ref, client);
    //   isHandlingEvents = true;
    // }

    ref.read(readyControllerProvider.notifier).setReady(true);

    return client;
  }

  /// Submit captcha with [captchaKey] and [captchaToken]
  Future<bool> submitCaptcha(String captchaKey, String captchaToken) async {
    return true;
  }

  /// Submit multi-factor authentication with [mfaToken]
  Future<FirebridgeGateway> submitMfa(String mfaToken) async {
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
      var resp = AuthSuccessMapper.fromMap(jsonDecode(response.body));
      return loginWithToken(resp.token);
    } else if (response.statusCode == 400) {
      throw Exception("Invalid two-factor code");
    } else {
      throw Exception(response.body);
    }
  }

  /// Submit sms authentication with [phoneToken]
  Future<bool> submitPhoneAuth(String phoneToken) async {
    return true;
  }
}
