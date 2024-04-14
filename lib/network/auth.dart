import 'dart:convert';
import 'package:bonfire/providers/discord/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nyxx/nyxx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

checkPersistentToken(BuildContext ctx) {
  print("checking for token!");
  final box = GetStorage();
  var token = box.read('token');
  if (token != null) {
    print("Token found in storage! We can proceed with routing.");
    Nyxx.connectGateway(token!, GatewayIntents.allUnprivileged).then((client) {
      Navigator.of(ctx)
          .pushNamedAndRemoveUntil("/home", (r) => false, arguments: client);
    });
  }
}

class AuthUser {
  final String login;
  final String password;
  final WidgetRef ref;

  String? ticket;
  String? token;
  BuildContext ctx;
  NyxxGateway? client;
  bool clientCreated = false;

  AuthUser({
    required this.login,
    required this.password,
    required this.ref,
    required this.ctx,
  });

  var superProps = {
    'os': 'Windows',
    'browser': 'Chrome',
    'device': '',
    'browser_user_agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36',
    'browser_version': '96.0.4664.110',
    'os_version': '10',
    'referrer': '',
    'referring_domain': '',
    'referrer_current': '',
    'referring_domain_current': '',
    'release_channel': 'stable',
    'system_locale': 'en-US',
    'client_build_number': 844,
    'client_event_source': null,
    'design_id': 0,
  };

  Map<String, String> _getHeaders() => {
        "X-Discord-Timezone": "America/New_York",
        "Sec-Ch-Ua-Platform": '"Windows"',
        'Accept-Language': 'en-US',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Origin': 'https://discord.com',
        'Pragma': 'no-cache',
        'Referer': 'https://discord.com/channels/@me',
        'Sec-CH-UA':
            '"Google Chrome";v="96", "Chromium";v=96", ";Not-A.Brand";v="24"',
        'Sec-CH-UA-Mobile': '?0',
        'Sec-CH-UA-Platform': '"Windows"',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-origin',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36',
        'X-Discord-Locale': 'en-US',
        'X-Debug-Options': 'bugReporterEnabled',
        "X-Super-Properties": base64Encode(utf8.encode(jsonEncode(superProps))),
        "Content-Type": "application/json"
      };

  Future<http.Response> post() {
    var headers = _getHeaders();
    var body = {
      'gift_code_sku_id': null,
      'login': login,
      'login_source': null,
      'password': password,
      'undelete': false,
    };

    final resp = http.post(Uri.parse("https://discord.com/api/v9/auth/login"),
        headers: headers, body: jsonEncode(body));

    resp.then((value) {
      ticket = jsonDecode(value.body)["ticket"];
      token = jsonDecode(value.body)["token"];
      if (token != null) {
        print("Got token! We can proceed with routing.");
        _createAndNotifyClient();
      } else {
        if (ticket != null) {
          print("Got ticket! We need to do MFA.");
        } else {
          print(
              "Neither a token or ticket was recieved; something went wrong. Check the response body. ");
          print(value.body);
        }
      }
    });

    return resp;
  }

  Future<http.Response> postMFA(String code) {
    var headers = _getHeaders();
    var body = {
      'code': int.parse(code),
      'gift_code_sku_id': null,
      'login_source': null,
      'ticket': ticket,
    };

    final resp = http.post(
        Uri.parse("https://discord.com/api/v9/auth/mfa/totp"),
        headers: headers,
        body: jsonEncode(body));
    resp.then((value) {
      token = jsonDecode(value.body)["token"];
      if (token != null) {
        print("Got token! We can proceed with routing.");

        _createAndNotifyClient();
      } else {
        print(
            "No token was recieved; something went wrong. Check the response body.");
        print(value.body);
      }
    });
    return resp;
  }

  _createAndNotifyClient() {
    if (clientCreated) return;
    clientCreated = true;

    final box = GetStorage();
    box.write('token', token);

    Nyxx.connectGateway(token!, GatewayIntents.allUnprivileged).then((client) {
      Navigator.of(ctx)
          .pushNamedAndRemoveUntil("/home", (r) => false, arguments: client);
    });
  }
}
