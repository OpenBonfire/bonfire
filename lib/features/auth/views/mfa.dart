import 'package:bonfire/features/auth/data/repositories/auth.dart';
import 'package:bonfire/shared/widgets/confirm_button.dart';
import 'package:bonfire/theme/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MFAPage extends ConsumerStatefulWidget {
  const MFAPage({super.key});

  @override
  ConsumerState<MFAPage> createState() => _MFAPageState();
}

class _MFAPageState extends ConsumerState<MFAPage> {
  TextEditingController controller = TextEditingController();

  Widget mfaBox() {
    return SizedBox(
      width: 400,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "MULTI FACTOR CODE",
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
                    autofillHints: const [AutofillHints.oneTimeCode],
                    autocorrect: true,
                    textAlign: TextAlign.center,
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

  submitMFA() async {
    var resp = ref.read(authProvider.notifier).submitMfa(controller.text);

    resp.then((value) {
      print("GOT MFA RESP!");
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).viewPadding.top;
    var bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
            padding: EdgeInsets.only(
              top: topPadding,
              bottom: bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Multi Factor Authentication",
                  style: CustomTextTheme().titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    "Enter your second factor code. This can be found in your authenticator app.",
                    style: CustomTextTheme().subtitle1.copyWith(
                          color: Theme.of(context).colorScheme.background,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                Center(child: mfaBox()),
                const Expanded(
                  child: SizedBox(),
                ),
                ConfirmButton(
                    text: "Sign In",
                    onPressed: () async {
                      print(await submitMFA());
                    })
              ],
            ),
          )
        ],
      ),
    );
  }
}
