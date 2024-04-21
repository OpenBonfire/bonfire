import 'dart:ui';

import 'package:flutter/material.dart';

class AppColorsDark {
  static const backgroundColor = Color(0xFF131318);
  static const textColor1 = Color(0xFFE4E5E8);
  static const textColor2 = Color(0xFF9597A3);
  static const selectedIconColor = Color(0xFFE4E5E8);
  static const deselectedIconColor = Color(0xFF72767D);

  static const blurpleColor = Color(0xFF7289DA);
  static const redColor = Color(0xFFED4245);
  static const greenColor = Color(0xFF57F287);
  static const yellowColor = Color(0xFFFEE75C);
  static const foreground = Color(0xFF1C1D22);
  static const cardSelected = Color(0xFF26272F);
  static const brightestGray = Color(0xFF383A43);
}

// todo: implement
class AppColorsLight {
  static const backgroundColor = Color(0xFF131318);
  static const textColor1 = Color(0xFFE4E5E8);
  static const textColor2 = Color(0xFF9597A3);
  static const selectedIconColor = Color(0xFFE4E5E8);
  static const deselectedIconColor = Color(0xFF72767D);
  static const foreground = Color(0xFF1C1D22);
  static const cardSelected = Color(0xFF26272F);
  static const brightestGray = Color(0xFF383A43);

  static const blurpleColor = Color(0xFF7289DA);
  static const redColor = Color(0xFFED4245);
  static const greenColor = Color(0xFF57F287);
  static const yellowColor = Color(0xFFFEE75C);
}

class ColorTheme {
  final Color backgroundColor;
  final Color textColor1;
  final Color textColor2;
  final Color selectedIconColor;
  final Color deselectedIconColor;

  final Color blurpleColor;
  final Color redColor;
  final Color greenColor;
  final Color yellowColor;
  final Color foreground;
  final Color cardSelected;
  final Color brightestGray;

  ColorTheme({
    required this.backgroundColor,
    required this.textColor1,
    required this.textColor2,
    required this.selectedIconColor,
    required this.deselectedIconColor,
    required this.blurpleColor,
    required this.redColor,
    required this.greenColor,
    required this.yellowColor,
    required this.foreground,
    required this.cardSelected,
    required this.brightestGray,
  });
}
