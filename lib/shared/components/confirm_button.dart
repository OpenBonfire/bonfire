import 'package:bonfire/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmButton extends StatefulWidget {
  final String text;
  final void Function() onPressed;

  const ConfirmButton({super.key, required this.text, required this.onPressed});

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: widget.onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.all(0),
        side: const BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        foregroundColor: BonfireThemeExtension.of(context).dirtyWhite,
        backgroundColor: BonfireThemeExtension.of(context).foreground,
      ),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: BonfireThemeExtension.of(context).primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            widget.text,
            style: GoogleFonts.publicSans(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
