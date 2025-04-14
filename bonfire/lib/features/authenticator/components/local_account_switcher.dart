import 'package:bonfire/features/authenticator/components/platform_login.dart';
import 'package:bonfire/features/authenticator/controllers/added_accounts.dart';
import 'package:bonfire/features/authenticator/models/added_account.dart';
import 'package:bonfire/features/authenticator/repositories/auth.dart';
import 'package:bonfire/features/authenticator/repositories/discord_auth.dart';
import 'package:bonfire/shared/components/confirm_button.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

          // if is mounted
          if (mounted) {
            Navigator.pop(context);
            setState(() {
              isLoading = false;
            });
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
    final theme = Theme.of(context).custom;
    final padding = shouldUseMobileLayout(context)
        ? MediaQuery.of(context).padding
        : EdgeInsets.zero;
    final addedAccounts = ref.watch(addedAccountsControllerProvider);
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      padding: EdgeInsets.only(
          top: padding.top + 24,
          left: 24,
          right: 24,
          bottom: padding.bottom + 24),
      decoration: BoxDecoration(
        color: Theme.of(context).custom.colorTheme.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Switch Account",
                  style: theme.textTheme.titleMedium.copyWith(
                      color: theme.colorTheme.dirtyWhite,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                ...addedAccounts.map((account) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _LocalAccountCard(account, onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        isLoading = true;
                      });
                      ref
                          .read(authProvider.notifier)
                          .loginWithToken(account.token);
                    }),
                  );
                }),
              ],
            ),
          ),
          const Spacer(),
          ConfirmButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return const Dialog(child: PlatformLoginWidget());
                  },
                );
              },
              text: "Add Account"),
        ],
      ),
    );
  }
}

class _LocalAccountCard extends ConsumerWidget {
  final AddedAccount account;
  final Function() onPressed;
  const _LocalAccountCard(this.account, {required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.all(4),
        side: const BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        foregroundColor: Theme.of(context).custom.colorTheme.dirtyWhite,
        backgroundColor: Theme.of(context).custom.colorTheme.foreground,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                  width: 35,
                  child: ClipOval(
                      child: CachedNetworkImage(imageUrl: account.avatar))),
              const SizedBox(width: 12),
              Text(account.username,
                  style: Theme.of(context).custom.textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}
