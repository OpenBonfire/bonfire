import 'dart:async';

import 'package:bonfire/providers/discord/auth.dart';
import 'package:flutter/material.dart';
import 'package:discord_api/discord_api.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/network/discord.dart';

const clientId = '1228043349550956644';
const clientSecret = 'InfdjO7ME9nVPBaTeotKe9CmUePx6d1m';
const redirectUri = 'https://www.google.com/';

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  var scopes = <DiscordApiScope>[];

  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _discordClient = DiscordClient(
    clientId: clientId,
    clientSecret: clientSecret,
    redirectUri: redirectUri,
    discordHttpClient:
        DiscordDioProvider(clientId: clientId, clientSecret: clientSecret),
  );

  var controller = InAppWebView();

  @override
  void initState() {
    super.initState();
    print("SCOPE INFO");
    print(DiscordApiScope.values.length);
    print(DiscordApiScope.values[6]);
  }

  @override
  Widget build(BuildContext context) {
    final url = _discordClient.authorizeUri(DiscordApiScope.values.getRange(0, 5).toList());
    return WebViewWidget(url: url.toString(), discordClient: _discordClient);
  }
}

class WebViewWidget extends ConsumerStatefulWidget {
  const WebViewWidget({super.key, required this.url, required this.discordClient});

  final String url;
  final DiscordClient discordClient;

  @override
  WebViewWidgetState createState() => WebViewWidgetState();
}

class WebViewWidgetState extends ConsumerState<WebViewWidget> {
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onLoadStop: (controller, url) async {
          if (url.toString().startsWith(redirectUri)) {
            final uri = Uri.parse(url.toString());
            final code = uri.queryParameters['code'];
            discordClient.getAccessToken(code!).then((_) {
              ref.read(discordAuthProvider.notifier).setObj(discordClient);
            });
          }
        },
      ),
    );
  }
}

