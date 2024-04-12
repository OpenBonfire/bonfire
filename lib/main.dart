import 'dart:async';

import 'package:flutter/material.dart';
import 'package:discord_api/discord_api.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const clientId = '1228043349550956644';
const clientSecret = 'InfdjO7ME9nVPBaTeotKe9CmUePx6d1m';
const redirectUri = 'https://www.google.com/';

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  final _discordClient = DiscordClient(
    clientId: clientId,
    clientSecret: clientSecret,
    redirectUri: redirectUri,
    discordHttpClient:
        DiscordDioProvider(clientId: clientId, clientSecret: clientSecret),
  );

  var controller = InAppWebView();
  var scopes = [
    DiscordApiScope.identify,
    DiscordApiScope.email,
    DiscordApiScope.guilds
  ];

  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = _discordClient.authorizeUri(scopes);
    return MaterialApp(
      title: 'Discord API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WebViewWidget(url: url.toString()),
    );
  }
}

class WebViewWidget extends StatefulWidget {
  final String url;

  WebViewWidget({required this.url});

  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  late InAppWebViewController _webViewController;

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
            _webViewController
            // final token = await _discordClient.getToken(code!);
            // print(token);
          }
        },
      ),
    );
  }
}
