import 'package:bonfire/features/authenticator/data/repositories/auth.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CaptchaView extends ConsumerStatefulWidget {
  const CaptchaView({
    super.key,
  });

  @override
  ConsumerState<CaptchaView> createState() => _CaptchaViewState();
}

class _CaptchaViewState extends ConsumerState<CaptchaView> {
  final TextEditingController _tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.foreground,
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
                  color:
                      Theme.of(context).custom.colorTheme.selectedChannelText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Because of the goofy way login works on web, you need to input your token in directly. This is for advanced users only.",
                style: GoogleFonts.publicSans(
                  fontSize: 16,
                  color:
                      Theme.of(context).custom.colorTheme.deselectedChannelText,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  hintText: 'Enter your token here',
                  filled: true,
                  fillColor: Theme.of(context).custom.colorTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.vpn_key,
                    color: Theme.of(context)
                        .custom
                        .colorTheme
                        .deselectedChannelText,
                  ),
                ),
                style: GoogleFonts.publicSans(
                  fontSize: 16,
                  color:
                      Theme.of(context).custom.colorTheme.selectedChannelText,
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
                  backgroundColor:
                      Theme.of(context).custom.colorTheme.background,
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
      ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }
}
