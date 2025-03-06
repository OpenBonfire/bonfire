import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/shared/components/confirm_button.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MFAPage extends ConsumerStatefulWidget {
  const MFAPage({super.key});

  @override
  ConsumerState<MFAPage> createState() => _MFAPageState();
}

class _MFAPageState extends ConsumerState<MFAPage> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget mfaBox() {
    return SizedBox(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "MULTI FACTOR CODE",
            style: GoogleFonts.publicSans(
              color: const Color(0xFFC8C8C8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).custom.colorTheme.foreground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: CustomTextTheme().bodyText1,
                controller: controller,
                autofillHints: const [AutofillHints.oneTimeCode],
                autocorrect: false,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '',
                  hintStyle:
                      TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submitMFA() async {
    try {
      final resp =
          await ref.read(authProvider.notifier).submitMfa(controller.text);
      if (resp is MFAInvalidError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.error)),
        );
      } else {}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Multi Factor Authentication",
                        style: CustomTextTheme().titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Enter your second factor code. This can be found in your authenticator app.",
                        style: GoogleFonts.publicSans(
                          color: const Color(0xFFC8C8C8),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      mfaBox(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ConfirmButton(
                text: "Sign In",
                onPressed: submitMFA,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
