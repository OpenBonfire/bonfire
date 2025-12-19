import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewLoginScreen extends ConsumerStatefulWidget {
  const WebviewLoginScreen({super.key});

  @override
  ConsumerState<WebviewLoginScreen> createState() => _WebviewLoginScreenState();
}

class _WebviewLoginScreenState extends ConsumerState<WebviewLoginScreen> {
  bool webviewInitialized = false;
  final webviewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted);

  @override
  void dispose() {
    debugPrint("DISPOSING WEBVIEW");

    // widget.fireviewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    webviewController.loadRequest(Uri.parse("https://discord.com/login")).then((
      _,
    ) async {
      await webviewController.clearCache();
      await webviewController.clearLocalStorage();

      setState(() {
        webviewInitialized = true;
      });

      webviewController.runJavaScript(
        "document.body.style.backgroundColor = '#14161A';",
      );

      webviewController.setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) {
            print("URL: ${change.url}");
            if (change.url?.contains("@me") ?? false) {
              webviewController
                  .runJavaScriptReturningResult(
                    "(webpackChunkdiscord_app.push([[''],{},e=>{m=[];for(let c in e.c)m.push(e.c[c])}]),m).find(m=>m?.exports?.default?.getToken!==void 0).exports.default.getToken();",
                  )
                  .then((value) async {
                    // this sucks

                    await ref
                        .read(clientControllerProvider.notifier)
                        .loginWithToken((value as String).replaceAll('"', ""));

                    await webviewController.loadRequest(
                      Uri.parse("about:blank"),
                    );
                  });
            }
          },
        ),
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 40),
            Text(
              "Welcome Back!",
              style: Theme.of(context).textTheme.titleLarge!,
            ),
            Text(
              "Let's get ya signed in",
              style: GoogleFonts.publicSans(
                color: const Color(0xFFC8C8C8),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: webviewInitialized
                        ? WebViewWidget(controller: webviewController)
                        : const SizedBox(),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: bottomPadding + 12)),
          ],
        ),
      ],
    );
  }
}
