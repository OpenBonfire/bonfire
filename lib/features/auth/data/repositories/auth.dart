import 'dart:convert';

import 'package:bonfire/features/auth/data/headers.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nyxx/nyxx.dart';
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
      } else {
        final authObj = AuthSuccess.fromJson(json);
        NyxxGateway client =
            await Nyxx.connectGateway(authObj.token, GatewayIntents.all);

        authResponse = AuthUser(token: json['token'], client: client);
      }
    } else if (json.containsKey('captcha_key') &&
        json.containsKey('captcha_sitekey') &&
        json.containsKey('captcha_service')) {
      authResponse = CaptchaResponse.fromJson(json);
    } else {
      throw Exception('Unknown response');
    }
    authResponse = authResponse;
    state = authResponse;
    return authResponse;
  }

  Future<bool> loginWithToken(String token) async {
    return true;
  }

  Future<bool> submitCaptcha(String captchaKey, String captchaToken) async {
    return true;
  }

  Future<AuthSuccess> submitMfa(String mfaToken) async {
    print("mfa token");
    print(mfaToken);
    var body = {
      'code': int.parse(mfaToken),
      'gift_code_sku_id': null,
      'login_source': null,
      'ticket': (state as MFARequired).ticket,
    };

    print("ticket: ");
    print((state as MFARequired).ticket);

    final response = await http.post(
      Uri.https("discord.com", '/api/v9/auth/mfa/totp'),
      headers: Headers().getHeaders(),
      body: jsonEncode(body),
    );

    print("GOT RESPONSE!");
    print(response.body);

    return AuthSuccess.fromJson(jsonDecode(response.body));
  }

  Future<bool> submitPhoneAuth(String phoneToken) async {
    return true;
  }
}
