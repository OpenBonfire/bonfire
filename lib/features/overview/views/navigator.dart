import 'package:bonfire/features/overview/controllers/navigation_bar.dart';
import 'package:bonfire/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/features/overview/views/overlapping_panels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PopUpNavigationBar extends StatefulWidget {
  final OverlappingPanels panel;
  const PopUpNavigationBar({Key? key, required this.panel}) : super(key: key);

  @override
  _PopUpNavigationBarState createState() => _PopUpNavigationBarState();
}

class _PopUpNavigationBarState extends State<PopUpNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.panel,
        BarWidget(
          panel: widget.panel,
        )
      ],
    );
  }
}

class BarWidget extends ConsumerStatefulWidget {
  final OverlappingPanels panel;
  const BarWidget({Key? key, required this.panel}) : super(key: key);

  @override
  ConsumerState<BarWidget> createState() => _BarWidgetState();
}

class _BarWidgetState extends ConsumerState<BarWidget> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(navigationBarProvider);

    if (state == RevealSide.left) {
      visible = true;
    } else {
      visible = false;
    }
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
        child: Column(
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
                          icon: SvgPicture.asset(
                            'assets/icons/home.svg',
                            colorFilter: ColorFilter.mode(
                              Theme.of(context)
                                  .custom
                                  .colorTheme
                                  .selectedIconColor,
                              BlendMode.srcIn,
                            ),
                            height: 25,
                          ),
                          label: 'Home'),
                      NavigatorIcon(
                          icon: SvgPicture.asset(
                            'assets/icons/messages.svg',
                            colorFilter: ColorFilter.mode(
                              Theme.of(context)
                                  .custom
                                  .colorTheme
                                  .selectedIconColor,
                              BlendMode.srcIn,
                            ),
                            height: 25,
                          ),
                          label: 'Messages'),
                      NavigatorIcon(
                          icon: SvgPicture.asset(
                            'assets/icons/notifications.svg',
                            colorFilter: ColorFilter.mode(
                              Theme.of(context)
                                  .custom
                                  .colorTheme
                                  .selectedIconColor,
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
        ),
      ),
    );
  }
}

class NavigatorIcon extends StatefulWidget {
  final SvgPicture icon;
  final String label;
  const NavigatorIcon({super.key, required this.icon, required this.label});

  @override
  State<NavigatorIcon> createState() => NavigatorIconState();
}

class NavigatorIconState extends State<NavigatorIcon> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
