import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme getBaseTextTheme() {
  final baseTheme = GoogleFonts.interTextTheme();

  return baseTheme.copyWith(
    titleLarge: GoogleFonts.inter(fontWeight: .bold, fontSize: 22),
    titleMedium: GoogleFonts.inter(fontWeight: .bold, fontSize: 17),
    titleSmall: GoogleFonts.inter(fontWeight: .w600, fontSize: 15),
    labelLarge: GoogleFonts.inter(fontWeight: .w700, fontSize: 14.5),
    labelMedium: GoogleFonts.inter(fontWeight: .w500, fontSize: 13),
    labelSmall: GoogleFonts.inter(fontWeight: .w400, fontSize: 12),
    headlineMedium: GoogleFonts.inter(fontWeight: .w600, fontSize: 24),
    headlineSmall: GoogleFonts.inter(fontWeight: .w500, fontSize: 16),
    bodyLarge: GoogleFonts.inter(fontWeight: .w600, fontSize: 14.5),
    bodyMedium: GoogleFonts.inter(fontWeight: .w500, fontSize: 14.5),
    bodySmall: GoogleFonts.inter(fontWeight: .w500, fontSize: 11),
  );
}
