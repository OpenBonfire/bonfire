import 'dart:convert';

import 'package:bonfire/colors.dart';
import 'package:bonfire/network/auth.dart';
import 'package:bonfire/providers/discord/auth.dart';
import 'package:bonfire/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/colors.dart' as colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyxx/nyxx.dart' as nyxx;

class MultiFactorView extends ConsumerStatefulWidget {
  AuthUser authUser;
  MultiFactorView({super.key, required this.authUser});

  String mfaCode = '';
  String tempDebugReturn = '';

  @override
  ConsumerState<MultiFactorView> createState() => _MultiFactorViewState();
}

class _MultiFactorViewState extends ConsumerState<MultiFactorView> {
  Widget _mfaVerify() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: 400,
        height: 60,
        child: Container(
          decoration: BoxDecoration(
            color: foreground,
            border: Border.all(color: foregroundBright),
            borderRadius: BorderRadius.circular(10),
          ),
          // width: 400,
          // height: 60,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Center(
              child: TextField(
                autofillHints: const [AutofillHints.oneTimeCode],
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.subtitle,
                ),
                cursorColor: colors.title,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  widget.mfaCode = value;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginButton() {
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
                  widget.authUser.postMFA(widget.mfaCode).then((value) {
                    widget.authUser.token = jsonDecode(value.body)['token'];
                    setState(() {
                      widget.tempDebugReturn = value.body;
                      // Navigator.pushNamedAndRemoveUntil(
                      //     context, "/home", (r) => false, arguments: widget.authUser);
                    });
                  });
                },
                child: Text(
                  "VERIFY",
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(children: [
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: Text("Multi Factor Authentication",
                  style: titleStyle, textAlign: TextAlign.center),
            ),
          )),
          Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: SizedBox(
              child: Text(
                  "Enter your second factor code. This can be found in your authenticator app.",
                  style: subtitleStyle,
                  textAlign: TextAlign.center),
            ),
          )),
          const SizedBox(height: 32),
          _mfaVerify(),
          _loginButton(),
          Text(widget.tempDebugReturn)
        ]),
      ),
    );
  }
}
