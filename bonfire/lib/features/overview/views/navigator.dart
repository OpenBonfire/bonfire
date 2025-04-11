import 'package:bonfire/features/authenticator/components/local_account_switcher.dart';
import 'package:bonfire/features/authenticator/utils/switcher.dart';
import 'package:bonfire/features/overview/controllers/navigation_bar.dart';
import 'package:bonfire/features/user/card/repositories/self_user.dart';
import 'package:bonfire/features/user/components/presence_avatar.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';

class NavigationBarWidget extends ConsumerStatefulWidget {
  const NavigationBarWidget({super.key});

  @override
  ConsumerState<NavigationBarWidget> createState() => _BarWidgetState();
}

class _BarWidgetState extends ConsumerState<NavigationBarWidget> {
  bool visible = false;
  Uri? _selectedPath;
  late final RouterDelegate routerDelegate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedPath();
      routerDelegate = GoRouter.of(context).routerDelegate;
      routerDelegate.addListener(_updateSelectedPath);
    });
  }

  @override
  void dispose() {
    routerDelegate.removeListener(_updateSelectedPath);
    super.dispose();
  }

  void _updateSelectedPath() {
    final routeInfo = GoRouter.of(context).routeInformationProvider.value;
    if (routeInfo.uri.pathSegments.isEmpty) {
      return;
    }
    setState(() {
      _selectedPath = routeInfo.uri;
    });
  }

  Widget barComponent() {
    var lastLocation = Hive.box("last-location");
    String guildId = lastLocation.get("guildId") ?? '0';
    String channelId = lastLocation.get("channelId") ?? '0';

    var seg = _selectedPath?.pathSegments;

    bool? isHome;
    bool? isMessages;
    bool? isNotifications;

    isHome = (seg?[0] == 'channels') && (seg?[1] != '@me');
    isMessages = seg?[0] == 'channels' && seg?[1] == '@me';
    isNotifications = seg?[0] == 'overview' && seg?[1] == 'notifications';

    if (shouldUseDesktopLayout(context)) return Container();

    final user = ref.watch(selfUserProvider).valueOrNull;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.darkGray,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).custom.colorTheme.foreground,
                width: 1,
              ),
            ),
          ),
          height: 55,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 18, right: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NavigatorIcon(
                  path: '/channels/$guildId/$channelId',
                  iconAsset: 'assets/icons/home.svg',
                  label: 'Home',
                  selected: isHome,
                ),
                NavigatorIcon(
                  path: '/overview/notifications',
                  iconAsset: 'assets/icons/notifications.svg',
                  label: 'Notifications',
                  selected: isNotifications,
                ),
                // this should just be a custom thing
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      child: PresenceAvatar(userId: user.id, size: 32),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        showAccountSwitcherDialog(
                            context, GoRouter.of(context));
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.darkGray,
          ),
          height: MediaQuery.of(context).padding.bottom,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(navigationBarProvider);
    visible = state == RevealSide.left;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: visible ? 0 : -80 - MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      curve: Curves.ease,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.linear,
        )),
        child: barComponent(),
      ),
    );
  }
}

class NavigatorIcon extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String? path;
  final Function()? onTap;
  final bool selected;

  const NavigatorIcon({
    super.key,
    required this.iconAsset,
    required this.label,
    this.path,
    this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).custom.colorTheme.dirtyWhite
        : Theme.of(context).custom.colorTheme.gray;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        if (path != null) GoRouter.of(context).push(path!);
        if (onTap != null) onTap!();
      },
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 75,
        child: Column(
          children: [
            SvgPicture.asset(
              iconAsset,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              height: 25,
            ),
            DefaultTextStyle(
              style: Theme.of(context).custom.textTheme.subtitle2.copyWith(
                    fontSize: 9,
                    color: color,
                  ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).custom.textTheme.subtitle2.copyWith(
                      fontSize: 9,
                      color: color,
                    ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
