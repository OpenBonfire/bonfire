import 'dart:math';

import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class TokenLoginWidget extends ConsumerStatefulWidget {
  const TokenLoginWidget({
    super.key,
  });

  @override
  ConsumerState<TokenLoginWidget> createState() => _TokenLoginWidgetState();
}

class _TokenLoginWidgetState extends ConsumerState<TokenLoginWidget> {
  final TextEditingController _tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: min(MediaQuery.sizeOf(context).width - 20, 400),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: BonfireThemeExtension.of(context).foreground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Woah there, speedy!",
              style: GoogleFonts.publicSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: BonfireThemeExtension.of(context).dirtyWhite,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Due to recent restrictions put in place by Discord, I currently have disabled credential-based login. You must log in via QR code, or input your token.",
              style: GoogleFonts.publicSans(
                fontSize: 16,
                color: BonfireThemeExtension.of(context).gray,
              ),
              softWrap: true,
            ),
            const SizedBox(height: 24),
            TextSelectionTheme(
              data: TextSelectionThemeData(
                cursorColor: BonfireThemeExtension.of(context).primary,
                selectionColor: BonfireThemeExtension.of(context).primary,
                selectionHandleColor: BonfireThemeExtension.of(context).primary,
              ),
              child: TextField(
                controller: _tokenController,
                obscureText: true,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'Enter your token here',
                  hintStyle: GoogleFonts.publicSans(
                    fontSize: 16,
                    color: BonfireThemeExtension.of(context).gray,
                  ),
                  filled: true,
                  fillColor: BonfireThemeExtension.of(context).background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.vpn_key,
                    color: BonfireThemeExtension.of(context).gray,
                  ),
                ),
                style: GoogleFonts.publicSans(
                  fontSize: 16,
                  color: BonfireThemeExtension.of(context).dirtyWhite,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final token = _tokenController.text.trim();
                if (token.isNotEmpty) {
                  ref.read(authProvider.notifier).loginWithToken(token);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BonfireThemeExtension.of(context).primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  'Login',
                  style: GoogleFonts.publicSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }
}
