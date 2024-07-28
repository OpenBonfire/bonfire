import 'package:bonfire/features/overview/controllers/navigation_bar.dart';
import 'package:bonfire/shared/utils/platform.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

class NavigationBarWidget extends ConsumerStatefulWidget {
  const NavigationBarWidget({super.key});

  @override
  ConsumerState<NavigationBarWidget> createState() => _BarWidgetState();
}

class _BarWidgetState extends ConsumerState<NavigationBarWidget> {
  bool visible = false;
  Uri? _selectedPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedPath();
      GoRouter.of(context).routerDelegate.addListener(_updateSelectedPath);
    });
  }

  @override
  void dispose() {
    GoRouter.of(context).routerDelegate.removeListener(_updateSelectedPath);
    super.dispose();
  }

  void _updateSelectedPath() {
    final Uri currentLocation =
        GoRouter.of(context).routeInformationProvider.value.uri;
    setState(() {
      _selectedPath = currentLocation;
    });
  }

  Widget barComponent() {
    var lastLocation = Hive.box("last-location");
    String guildId = lastLocation.get("guildId") ?? '0';
    String channelId = lastLocation.get("channelId") ?? '0';

    var _seg = _selectedPath?.pathSegments;

    bool? isHome;
    bool? isMessages;
    bool? isNotifications;

    isHome = (_seg?[0] == 'channels') && (_seg?[1] != '@me');
    isMessages = _seg?[0] == 'channels' && _seg?[1] == '@me';
    isNotifications = _seg?[0] == 'overview' && _seg?[1] == 'notifications';

    if (shouldUseDesktopLayout(context)) return Container();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.navbarBackground,
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
              children: [
                NavigatorIcon(
                  path: '/channels/$guildId/$channelId',
                  iconAsset: 'assets/icons/home.svg',
                  label: 'Home',
                  selected: isHome,
                ),
                NavigatorIcon(
                  path: '/channels/@me',
                  iconAsset: 'assets/icons/messages.svg',
                  label: 'Messages',
                  selected: isMessages,
                ),
                NavigatorIcon(
                  path: '/overview/notifications',
                  iconAsset: 'assets/icons/notifications.svg',
                  label: 'Notifications',
                  selected:
                      isNotifications, // This is never selected in the current setup
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.navbarBackground,
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
  final String path;
  final bool selected;

  const NavigatorIcon({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.path,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).custom.colorTheme.navbarIconSelected
        : Theme.of(context).custom.colorTheme.navbarIconDeselected;

    return InkWell(
      onTap: () {
        GoRouter.of(context).push(path);
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
