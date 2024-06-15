import 'package:bonfire/features/overview/controllers/navigation_bar.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class BarWidget extends ConsumerStatefulWidget {
  const BarWidget({super.key});

  @override
  ConsumerState<BarWidget> createState() => _BarWidgetState();
}

class _BarWidgetState extends ConsumerState<BarWidget> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
  }

  Widget barComponent() {
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
              color: Theme.of(context).custom.colorTheme.cardSelected,
              border: Border(
                  top: BorderSide(
                color: Theme.of(context).custom.colorTheme.brightestGray,
                width: 1,
              )),
            ),
            height: 55,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 18, right: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavigatorIcon(
                      path: '/overview/home',
                      icon: SvgPicture.asset(
                        'assets/icons/home.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).custom.colorTheme.selectedIconColor,
                          BlendMode.srcIn,
                        ),
                        height: 25,
                      ),
                      label: 'Home'),
                  NavigatorIcon(
                      path: '/overview/messages',
                      icon: SvgPicture.asset(
                        'assets/icons/messages.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).custom.colorTheme.selectedIconColor,
                          BlendMode.srcIn,
                        ),
                        height: 25,
                      ),
                      label: 'Messages'),
                  NavigatorIcon(
                      path: '/overview/notifications',
                      icon: SvgPicture.asset(
                        'assets/icons/notifications.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).custom.colorTheme.selectedIconColor,
                          BlendMode.srcIn,
                        ),
                        height: 25,
                      ),
                      label: 'Notifications'),
                ],
              ),
            )),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).custom.colorTheme.cardSelected,
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

class NavigatorIcon extends StatefulWidget {
  final SvgPicture icon;
  final String label;
  final String path;
  const NavigatorIcon(
      {super.key, required this.icon, required this.label, required this.path});

  @override
  State<NavigatorIcon> createState() => NavigatorIconState();
}

class NavigatorIconState extends State<NavigatorIcon> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        GoRouter.of(context).push(widget.path);
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        side: const BorderSide(
          color: Color.fromARGB(0, 255, 255, 255),
          width: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      child: SizedBox(
        width: 75,
        child: Column(
          children: [
            widget.icon,
            Text(widget.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).custom.textTheme.subtitle2.copyWith(
                      fontSize: 9,
                      color:
                          Theme.of(context).custom.colorTheme.selectedIconColor,
                    ))
          ],
        ),
      ),
    );
  }
}
