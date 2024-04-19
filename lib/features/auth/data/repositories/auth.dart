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

  @override
  Future<TestAuth> build() async {
    return TestAuth(test: "asd");
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
    var authResponse;

    if (json.containsKey('user_id') && json.containsKey('mfa')) {
      var success = AuthSuccess.fromJson(json);
      NyxxGateway client =
          await Nyxx.connectGateway(success.token!, GatewayIntents.all);

      authResponse = AuthUser(token: json['token'], client: client);
    } else if (json.containsKey('captcha_key') &&
        json.containsKey('captcha_sitekey') &&
        json.containsKey('captcha_service')) {
      print("got json: ");
      print(json);
      authResponse = CaptchaResponse.fromJson(json);
    } else {
      throw Exception('Unknown response');
    }

    return authResponse;
  }

  Future<bool> loginWithToken(String token) async {
    return true;
  }

  Future<bool> completeCaptcha(String captchaKey, String captchaToken) async {
    return true;
  }

  Future<bool> completeMfa(String mfaToken) async {
    return true;
  }

  Future<bool> completePhoneAuth(String phoneToken) async {
    return true;
  }
}
