import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/data/repositories/discord_auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/shared/repositories/firebridge/auth.dart';

void main() async {
  await GetStorage.init();
  runApp(const ProviderScope(child: MaterialApp(home: AuthWidgetTest())));
}

class AuthWidgetTest extends ConsumerStatefulWidget {
  const AuthWidgetTest({Key? key}) : super(key: key);

  @override
  _AuthWidgetTestState createState() => _AuthWidgetTestState();
}

class _AuthWidgetTestState extends ConsumerState<AuthWidgetTest> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor:
          Colors.transparent, // This makes navigation bar transparent
      systemNavigationBarIconBrightness:
          Brightness.dark, // You can set the icons' color to dark
      statusBarColor:
          Colors.transparent, // This makes the status bar transparent
    ));

    final MediaQueryData queryData = MediaQuery.of(context);
    final Size viewportSize = queryData.size;

    String buttonText = "Login";
    var auth = ref.watch(authProvider);
    auth.when(
      data: (data) {
        if (data is AuthSuccess) {
          buttonText = "Logged in";
        } else if (data is CaptchaResponse) {
          buttonText = "Captcha";
        }
      },
      loading: () {
        buttonText = "Loading";
      },
      error: (error, stack) {
        buttonText = "Error";
      },
    );

    return Scaffold(
      resizeToAvoidBottomInset: false, // To avoid resizing due to keyboard
      body: Container(
        padding: EdgeInsets.only(
            bottom:
                Platform.isAndroid ? 16.0 : 0), // Adjust padding for Android
        child: Center(
          child: ElevatedButton(
            onPressed: () async {
              var resp = await ref
                  .read(authProvider.notifier)
                  .loginWithCredentials("username", "password");

              print(resp);
            },
            child: Text(buttonText),
          ),
        ),
      ),
    );
  }
}
