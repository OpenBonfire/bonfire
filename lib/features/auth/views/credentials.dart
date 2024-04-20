import 'package:bonfire/features/auth/controllers/text_controllers.dart';
import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/features/auth/models/auth.dart';
import 'package:bonfire/features/auth/views/mfa.dart';
import 'package:bonfire/shared/widgets/confirm_button.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CredentialsScreen extends ConsumerStatefulWidget {
  const CredentialsScreen({super.key});

  @override
  ConsumerState<CredentialsScreen> createState() => _LoginState();
}

enum LoginType { username, password }

class _LoginState extends ConsumerState<CredentialsScreen> {
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
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              loginType == LoginType.username ? "Username" : "Password",
              style: CustomTextTheme().labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.background,
                  ),
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 22, 20, 20),
              borderRadius: BorderRadius.circular(0),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: CustomTextTheme().bodyText2,
                    controller: controller,
                    obscureText: loginType == LoginType.password,
                    autofillHints: loginType == LoginType.username
                        ? [AutofillHints.username]
                        : [AutofillHints.password],
                    autocorrect: true,
                    decoration: const InputDecoration(
                      hintText: '',
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
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
        .loginWithCredentials(username, password);
  }

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).viewPadding.top;
    var bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
        body: Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/images/login_background.png',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: Column(
                children: [
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
                ],
              )),
              Form(
                child: AutofillGroup(
                  child: Column(children: [
                    Center(child: loginBox(LoginType.username)),
                    const SizedBox(height: 20),
                    Center(child: loginBox(LoginType.password)),
                  ]),
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              ConfirmButton(
                  text: "Confirm",
                  onPressed: () async {
                    context.go('/mfa');
                    print(await submitCredentials());
                  })
            ],
          ),
        ),
      ],
    ));
  }
}
