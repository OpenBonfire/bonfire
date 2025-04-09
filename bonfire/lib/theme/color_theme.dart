import 'dart:ui';
import 'package:flutter/material.dart';

class AppColorsDark {
  static const background = Color(0xFF14161A);
  static const foreground = Color(0xFF21252B);
  static const dirtyWhite = Color(0xFFE4E5E8);
  static const gray = Color(0xFF818491);
  static const darkGray = Color(0xFF18191f);
  static const primary = Color(0xff2448BE);
  static const red = Color(0xFFED4245);
  static const green = Color(0xFF57F287);
  static const yellow = Color(0xFFFEE75C);
}

class ColorTheme {
  final Color background;
  final Color foreground;
  final Color dirtyWhite;
  final Color gray;
  final Color darkGray;
  final Color primary;
  final Color red;
  final Color green;
  final Color yellow;

  ColorTheme({
    required this.background,
    required this.foreground,
    required this.dirtyWhite,
    required this.gray,
    required this.darkGray,
    required this.primary,
    required this.red,
    required this.green,
    required this.yellow,
  });
}
