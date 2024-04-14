import 'dart:ffi';
import 'dart:io';

import 'package:bonfire/components/sidebar/sidebar.dart';
import 'package:bonfire/globals.dart';
import 'package:bonfire/network/auth.dart';
import 'package:bonfire/style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyxx/nyxx.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ModalRoute.of(context)!.settings.arguments as NyxxGateway;
    globalClient = client;

    return MaterialApp(
      title: 'GuildCable',
      theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: backgroundColor,
          primaryColor: primaryColor,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: secondaryColor),
          textTheme: TextTheme(
            headlineMedium: GoogleFonts.roboto(
              fontSize: 48,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            bodyMedium: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white,
            ),
          )),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: backgroundColor,
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Sidebar(),
            ],
          ),
        ));
  }
}