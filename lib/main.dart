import 'dart:async';

import 'package:bonfire/views/home.dart';
import 'package:flutter/material.dart';
import 'package:discord_api/discord_api.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bonfire/providers/discord/auth.dart';
import 'package:bonfire/views/login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: Bonfire()));
}

class Bonfire extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(discordAuthProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: const Color(0xFF282b30),
        ),
        body: Center(
          child: (profile != null) ? const Home() : LoginPage()
        ),
      ),
    );
  }
}