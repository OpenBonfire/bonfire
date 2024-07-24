import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/shared/widgets/confirm_button.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return SizedBox(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loginType == LoginType.username ? "Email" : "Password",
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
                hintStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
        ],
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
    return Scaffold(
      // body: SafeArea(
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Welcome Back!",
                    style: CustomTextTheme().titleLarge,
                  ),
                  Text(
                    "Let's get ya signed in!",
                    style: CustomTextTheme().subtitle1.copyWith(
                          color: Theme.of(context).colorScheme.background,
                        ),
                  ),
                  const SizedBox(height: 80),
                  Form(
                    child: AutofillGroup(
                      child: Column(
                        children: [
                          loginBox(LoginType.username),
                          const SizedBox(height: 20),
                          loginBox(LoginType.password),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ConfirmButton(text: "CONFIRM", onPressed: submitCredentials),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      //),
    );
  }
}
