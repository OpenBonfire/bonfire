import 'package:bonfire/features/authenticator/components/platform_login.dart';
import 'package:bonfire/features/authenticator/controllers/added_accounts.dart';
import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/views/login.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalAccountSwitcherScreen extends ConsumerStatefulWidget {
  const LocalAccountSwitcherScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LocalAccountSwitcherScreenState();
}

class _LocalAccountSwitcherScreenState
    extends ConsumerState<LocalAccountSwitcherScreen> {
  @override
  Widget build(BuildContext context) {
    final addedAccounts = ref.watch(addedAccountsControllerProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text(
            "Switch Account",
          ),
          const SizedBox(height: 16),
          ...addedAccounts.map((account) {
            return ListTile(
              title: Text(account.username),
              onTap: () {
                ref.read(authProvider.notifier).loginWithToken(account.token);
                Navigator.pop(context);
              },
            );
          }).toList(),
          const SizedBox(height: 16),
          OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return const Dialog(child: PlatformLoginWidget());
                  },
                );
              },
              child: const Text("Add Account")),
        ],
      ),
    );
  }
}
