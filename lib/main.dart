import 'package:flutter/material.dart';
import 'package:guildcable/components/sidebar/sidebar.dart';
import 'package:guildcable/network/discord.dart';
import 'package:guildcable/style.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  print(discordClient.);
  runApp(const GuildCable());
}

class GuildCable extends StatelessWidget {
  const GuildCable({super.key});

  @override
  Widget build(BuildContext context) {
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: backgroundColor,
        ),
        body: const Row(
          children: [
            Sidebar(),
          ],
        ));
  }
}
