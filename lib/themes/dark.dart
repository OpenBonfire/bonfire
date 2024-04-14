import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bonfire/colors.dart' as colors;

final darkTheme = ThemeData(
  textSelectionTheme: const TextSelectionThemeData(
  selectionHandleColor: colors.success,
  ),
  primaryColor: const Color(0xFF1C1E24),
  scaffoldBackgroundColor: colors.background,
  highlightColor: const Color(0xFF6D6D6D),
  focusColor: const Color(0xFFC8C8C8),
  appBarTheme: const AppBarTheme(
    backgroundColor: colors.background,
    foregroundColor: Colors.white,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.grey,
  ),
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.istokWeb(
      color: const Color(0xFFC8C8C8),
      fontSize: 16,
    ),
  ),
);