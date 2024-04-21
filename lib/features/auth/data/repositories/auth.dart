import 'dart:convert';

import 'package:bonfire/features/auth/data/headers.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:nyxx_self/nyxx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

@riverpod
class Auth extends _$Auth {
  NyxxGateway? client;
  AuthResponse? authResponse;

  @override
  AuthResponse? build() {
    return authResponse;
  }

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
      headers: Headers().getHeaders(),
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
    } else {
      throw Exception('Unknown response');
    }

    return authResponse;
  }

  /// Authenticate client with Discord [token]
  Future<AuthResponse> loginWithToken(String token) async {
    var newClient =
        await Nyxx.connectGateway(token, GatewayIntents.allUnprivileged);
    client = newClient;

    // This is how we save login information
    GetStorage().write('token', token);

    // Save and notify state
    authResponse = AuthUser(token: token, client: client!);
    state = authResponse!;

    client!.onReady.listen((event) {
      print("Bot Ready!");
    });

    return authResponse!;
  }

  Future<bool> submitCaptcha(String captchaKey, String captchaToken) async {
    return true;
  }

  Future<AuthResponse> submitMfa(String mfaToken) async {
    var body = {
      'code': int.parse(mfaToken),
      'gift_code_sku_id': null,
      'login_source': null,
      'ticket': (state as MFARequired).ticket,
    };

    final response = await http.post(
      Uri.https("discord.com", '/api/v9/auth/mfa/totp'),
      headers: Headers().getHeaders(),
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

  Future<bool> submitPhoneAuth(String phoneToken) async {
    return true;
  }

  AuthResponse? getAuth() {
    return authResponse;
  }
}
