import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:fireview/fireview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CredentialsScreen extends ConsumerStatefulWidget {
  final FireviewController fireviewController;
  const CredentialsScreen({
    super.key,
    required this.fireviewController,
  });

  @override
  ConsumerState<CredentialsScreen> createState() => _LoginState();
}

enum LoginType { username, password }

class _LoginState extends ConsumerState<CredentialsScreen> {
  bool fireviewInitialized = false;

  @override
  void dispose() {
    print("DISPOSING FIREVIEW");
    widget.fireviewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    widget.fireviewController
        .initialize(Uri.parse("https://discord.com/login"))
        .then((_) async {
      await widget.fireviewController.clearCookies();
      await widget.fireviewController.clearCache();

      setState(() {
        fireviewInitialized = true;
      });

      widget.fireviewController.evaluateJavascript(
          "document.body.style.backgroundColor = '#14161A';");

      widget.fireviewController.urlStream.listen((url) async {
        if (url.toString() == "https://discord.com/channels/@me") {
          widget.fireviewController
              .evaluateJavascript(
                  "(webpackChunkdiscord_app.push([[''],{},e=>{m=[];for(let c in e.c)m.push(e.c[c])}]),m).find(m=>m?.exports?.default?.getToken!==void 0).exports.default.getToken();")
              .then((value) async {
            await ref
                .read(authProvider.notifier)
                .loginWithToken((value as String).replaceAll('"', ""));
          });

          // not a huge fan, but until I figure out how webview_flutter disposal is supposed to work
          widget.fireviewController.loadUrl(Uri.parse("about:blank"));
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 40),
              Text(
                "Welcome Back!",
                style: CustomTextTheme().titleLarge,
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
                      child: fireviewInitialized
                          ? Fireview(controller: widget.fireviewController)
                          : const SizedBox(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: bottomPadding + 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
