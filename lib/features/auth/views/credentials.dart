import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/shared/widgets/confirm_button.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CredentialsScreen extends ConsumerStatefulWidget {
  final bool storeCredentials;
  const CredentialsScreen({super.key, required this.storeCredentials});

  @override
  ConsumerState<CredentialsScreen> createState() => _LoginState();
}

enum LoginType { username, password }

class _LoginState extends ConsumerState<CredentialsScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget loginBox(LoginType loginType) {
    TextEditingController controller = loginType == LoginType.username
        ? usernameController
        : passwordController;

    return Center(
      child: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                loginType == LoginType.username ? "Email" : "Password",
                style: GoogleFonts.publicSans(
                  // todo: add this to the theme
                  color: const Color(0xFFC8C8C8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
                  obscureText: loginType == LoginType.password,
                  autofillHints: loginType == LoginType.username
                      ? [AutofillHints.username]
                      : [AutofillHints.password],
                  autocorrect: loginType == LoginType.username,
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
      ),
    );
  }

  Future<AuthResponse> submitCredentials() async {
    String username = usernameController.text;
    String password = passwordController.text;
    return await ref
        .read(authProvider.notifier)
        .loginWithCredentials(username, password, widget.storeCredentials);
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          "Welcome Back!",
                          style: CustomTextTheme().titleLarge,
                        ),
                        Text(
                          "Let's get ya signed in",
                          style: GoogleFonts.publicSans(
                            color: const Color(0xFFC8C8C8),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 80),
                        Form(
                          child: AutofillGroup(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                loginBox(LoginType.username),
                                const SizedBox(height: 20),
                                loginBox(LoginType.password),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: bottomPadding,
                ),
                child: ConfirmButton(
                  text: "CONFIRM",
                  onPressed: submitCredentials,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
