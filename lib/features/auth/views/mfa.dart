import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/shared/widgets/confirm_button.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            style: CustomTextTheme().labelLarge.copyWith(
                  color: Theme.of(context).colorScheme.background,
                ),
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 22, 20, 20),
              borderRadius: BorderRadius.circular(0),
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
        // Handle invalid MFA error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.error)),
        );
      } else {
        // Handle successful MFA submission
        // Navigate to next screen or show success message
      }
    } catch (e) {
      // Handle any unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/login_background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Multi Factor Authentication",
                    style: CustomTextTheme().titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Enter your second factor code. This can be found in your authenticator app.",
                    style: CustomTextTheme().subtitle1.copyWith(
                          color: Theme.of(context).colorScheme.background,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  mfaBox(),
                  const SizedBox(height: 40),
                  ConfirmButton(
                    text: "Sign In",
                    onPressed: submitMFA,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
