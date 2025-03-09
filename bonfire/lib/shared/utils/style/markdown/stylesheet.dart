import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_viewer/markdown_viewer.dart';

MarkdownStyle getMarkdownStyleSheet(BuildContext context) {
  return MarkdownStyle(
    paragraph: GoogleFonts.publicSans(
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFBDBDBD),
    ),
    codeBlock: GoogleFonts.jetBrainsMono(
      fontSize: 14,
    ),
    codeblockDecoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.foreground,
        borderRadius: BorderRadius.circular(8)),
    codeSpan: GoogleFonts.jetBrainsMono(
      backgroundColor: Theme.of(context).custom.colorTheme.foreground,
      fontSize: 14,
    ),
    list: GoogleFonts.publicSans(
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFBDBDBD),
    ),
    listItem: GoogleFonts.publicSans(
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFBDBDBD),
    ),
    headline1: GoogleFonts.publicSans(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFBDBDBD),
    ),
    headline2: GoogleFonts.publicSans(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFBDBDBD),
    ),
    headline3: GoogleFonts.publicSans(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFBDBDBD),
    ),
    headline4: GoogleFonts.publicSans(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFBDBDBD),
    ),
    headline5: GoogleFonts.publicSans(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFBDBDBD),
    ),
    headline6: GoogleFonts.publicSans(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFBDBDBD),
    ),
  );
}
