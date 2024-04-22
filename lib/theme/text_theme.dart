import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

String? _family = GoogleFonts.publicSans().fontFamily;

class CustomTextTheme {
  final titleLarge = TextStyle(
    fontSize: 36,
    fontFamily: _family,
    fontWeight: FontWeight.w600,
  );
  final titleMedium = TextStyle(
    fontSize: 24,
    fontFamily: _family,
    fontWeight: FontWeight.w600,
  );
  final titleSmall = TextStyle(
    fontSize: 20,
    fontFamily: _family,
    fontWeight: FontWeight.w600,
  );
  final labelLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: _family,
  );
  final subtitle1 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    fontFamily: _family,
  );
  final subtitle2 = TextStyle(
    fontSize: 14,
    fontFamily: _family,
  );
  final bodyText1 = TextStyle(
    fontSize: 16,
    fontFamily: _family,
  );
  final bodyText2 = TextStyle(
    fontSize: 15,
    fontFamily: _family,
  );
  final caption = TextStyle(
    fontSize: 12,
    fontFamily: _family,
  );
  final bold = TextStyle(
    fontWeight: FontWeight.w500,
    fontFamily: _family,
  );
}
