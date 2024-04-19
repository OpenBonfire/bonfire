import 'dart:convert';

import 'package:bonfire/features/auth/data/headers.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:http/http.dart' as http;
import 'package:nyxx/nyxx.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

Future<AuthUser> authWithToken(AuthRef ref, TokenUserAuth authenticator) async {
  print("token authentication");
  var user = AuthUser(token: authenticator.token, client: await Nyxx.connectGateway(authenticator.token, GatewayIntents.all));
  print("registed nyxx!");
  print(user);
  return user;
}

Future<AuthResponse> authWithCredentials(AuthRef ref, CredentialsUserAuth authenticator) async {
  final username = authenticator.username;
  final password = authenticator.password;

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
    authResponse = CaptchaResponse.fromJson(json);
  } else {
    throw Exception('Unknown response');
  }

  return authResponse;
}

@riverpod
Future<TestAuth> auth(AuthRef ref, LoginAuthenticator authenticator) async {
  return TestAuth(test: "asd");
  // if (authenticator is TokenUserAuth) {
  //   var tokenResp = AuthUser(token: authenticator.token, client: await Nyxx.connectGateway(authenticator.token, GatewayIntents.all)); // await authWithToken(ref, authenticator);
  //   var authed = CompletedAuth(authUser: tokenResp);
  //   print("returning auth, should be done...");
  //   return authed;
  // }
  //  else if (authenticator is CredentialsUserAuth) {
  //   return await authWithCredentials(ref, authenticator);
  // } else {
  //   throw Exception('Unknown authenticator');
  // }
}
