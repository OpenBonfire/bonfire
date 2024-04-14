import 'dart:async';
import 'dart:io';

import 'package:bonfire/providers/discord/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const clientId = '1228043349550956644';
const clientSecret = 'InfdjO7ME9nVPBaTeotKe9CmUePx6d1m';
const redirectUri = 'https://www.google.com/';

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var controller = InAppWebView();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const WebViewWidget(url: "https://discord.com/login");
  }
}

class WebViewWidget extends ConsumerStatefulWidget {
  const WebViewWidget({super.key, required this.url});

  final String url;

  @override
  WebViewWidgetState createState() => WebViewWidgetState();
}

class WebViewWidgetState extends ConsumerState<WebViewWidget> {
  late InAppWebViewController _webViewController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  getToken() {
    const grabTokenScript = """
      let token = null;
      window.webpackChunkdiscord_app.push([
        [Math.random()],
        {},
        req => {
          if (!req.c) return;
          for (const m of Object.keys(req.c)
            .map(x => req.c[x].exports)
            .filter(x => x)) {
            if (m.default && m.default.getToken !== undefined) {
              console.log(m.default.getToken());
              token = m.default.getToken();
            }
            if (m.getToken !== undefined) {
              console.log(m.getToken());
              token = m.getToken();
            }
          }
        },
      ]);
      console.log('%cWorked!', 'font-size: 50px');
      console.log(`%cYou now have your token in the clipboard!`, 'font-size: 16px');
      token;
    """;
    _webViewController.evaluateJavascript(source: grabTokenScript).then((value) {
      if (value != null && value != "") {
        print("Token: $value");
        // context.read(discordAuthProvider.notifier).setObj(value);
        _timer.cancel(); // Cancel the timer when the token is found
        // Navigator.pop(context); // Close the WebView when the token is found
      }
    });
  }

  startTimer() {
    // Start a timer to call getToken every second
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      getToken();
    });
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
          print("Loaded stopped, starting login listener");
          startTimer(); // Start the timer when the WebView finishes loading
        },
      ),
    );
  }
}
