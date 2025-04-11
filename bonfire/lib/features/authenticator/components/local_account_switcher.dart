import 'package:bonfire/features/authenticator/components/platform_login.dart';
import 'package:bonfire/features/authenticator/controllers/added_accounts.dart';
import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';

class LocalAccountSwitcherScreen extends ConsumerStatefulWidget {
  final GoRouter router;
  const LocalAccountSwitcherScreen(this.router, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LocalAccountSwitcherScreenState();
}

class _LocalAccountSwitcherScreenState
    extends ConsumerState<LocalAccountSwitcherScreen> {
  NyxxGateway? client;
  bool isLoading = false;

  @override
  void initState() {
    ref.listenManual(authProvider, (a, b) {
      if (b is AuthUser) {
        client = b.client;
        b.client.onReady.listen((_) {
          print("User is Ready!");
          // _navigateToLastLocation();
          setState(() {
            isLoading = false;
          });
          // if is mounted
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    });
    super.initState();
  }

  void _navigateToLastLocation() {
    var lastLocation = Hive.box("last-location");
    String? guildId = lastLocation.get("guildId");
    String? channelId = lastLocation.get("channelId");
    context.go('/channels/${guildId ?? '0'}/${channelId ?? '0'}');
  }

  @override
  Widget build(BuildContext context) {
    final addedAccounts = ref.watch(addedAccountsControllerProvider);
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
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
                setState(() {
                  isLoading = true;
                });
                ref.read(authProvider.notifier).loginWithToken(account.token);

                // print("GOING TO LOGIN!");
                // widget.router.go('/login');
              },
            );
          }),
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
