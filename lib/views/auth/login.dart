import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bonfire/colors.dart';
import 'package:bonfire/network/auth.dart';
import 'package:bonfire/styles/styles.dart';
import 'package:bonfire/views/auth/mfa.dart';
import 'package:bonfire/views/auth/selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonfire/colors.dart' as colors;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(LoginPage());
}

class LoginPage extends ConsumerStatefulWidget {
  String login = '';
  String password = '';
  bool errored = false;
  String lastErrorMessage = '';

  LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

enum TextBoxType {
  login,
  password,
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _loginBox(String title, TextBoxType type, [bool obscureText = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: 400,
        height: 90,
        child: Column(
          children: [
            Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "$title ${widget.errored ? " - ": ""} ${widget.lastErrorMessage}",
                  style: widget.errored ? erroredSubtitleStyle : subtitleStyle,
                  textAlign: TextAlign.left,
                )),
            Container(
              decoration: BoxDecoration(
                color: foreground,
                border: Border.all(color: foregroundBright),
                borderRadius: BorderRadius.circular(10),
              ),

              child: Padding(
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 2, bottom: 2),
                child: TextField(
                  obscureText: obscureText,
                  autofillHints: type == TextBoxType.login ? [AutofillHints.username, AutofillHints.email]: [AutofillHints.password],
                  style: subtitleStyle,
                  cursorColor: colors.title,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    if (widget.errored) {
                        setState(() {
                          widget.lastErrorMessage = '';
                          widget.errored = false;
                        });
                    }
                    if (type == TextBoxType.login) {
                      widget.login = value;
                    } else {
                      widget.password = value;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton(WidgetRef ref) {
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SizedBox(
            width: 400,
            height: 60,
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(colors.success),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                onPressed: () {
                  final authUser =
                      AuthUser(login: widget.login, password: widget.password, ref: ref);
                  authUser.post().then((response) {
                    final parsed = jsonDecode(response.body);

                    if (response.statusCode == 200) {
                      if (parsed["mfa"]) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MultiFactorView(authUser: authUser)),
                        );
                      }
                    } else {
                      if (parsed["errors"] != null) {
                        var message =
                            parsed["errors"]["login"]["_errors"][0]["message"];
                        setState(() {
                          widget.lastErrorMessage = message;
                          widget.errored = true;
                        });
                      } else {
                        var message = parsed["message"];
                        setState(() {
                          widget.lastErrorMessage = message ?? "An error occurred";
                          widget.errored = true;
                        });
                      }
                    }
                  });
                },
                child: Text(
                  "LOGIN",
                  style: GoogleFonts.inriaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.title,
                  ),
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(height: 20),
        Center(
            child: Text("Welcome back!",
                style: titleStyle, textAlign: TextAlign.center)),
        Center(
            child: Text("Let's get ya signed in!",
                style: subtitleStyle, textAlign: TextAlign.center)),
        const SizedBox(height: 30),
        _loginBox("USERNAME / EMAIL", TextBoxType.login),
        _loginBox("PASSWORD", TextBoxType.password, true),
        _loginButton(ref)
      ]),
    );
  }
}
